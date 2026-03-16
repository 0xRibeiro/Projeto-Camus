import logging
import random
from pathlib import Path
from logging.handlers import RotatingFileHandler
from datetime import datetime, timedelta

from flask import Flask, jsonify, request
from dotenv import load_dotenv
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import jwt

from database.db import criar_conexao, inicializar_banco
from model.user import Usuario
from repository.user_repository import RepositorioUsuario
from security import gerar_hash_senha, verificar_senha

from model.auth_code import AuthCode
from repository.auth_code_repository import AuthCodeRepository
from service.email_service import enviar_codigo

from model.session import Session
from repository.session_repository import SessionRepository
from service.token_service import gerar_token, validar_token

load_dotenv()

app = Flask(__name__)

# 1.11 Proteção contra força bruta implementada com rate limit por IP
limiter = Limiter(
    key_func=get_remote_address,
    app=app,
    storage_uri="memory://",
)

ERRO = {"error": "Erro interno ao processar a solicitacao"}


@app.errorhandler(429)
def tratar_rate_limit(_erro):
    return jsonify({"error": "Muitas tentativas. Tente novamente em instantes"}), 429


def configurar_logs():
    pasta_logs = Path(__file__).resolve().parent / "logs"
    pasta_logs.mkdir(parents=True, exist_ok=True)

    arquivo_log = pasta_logs / "camus_server.log"
    handler = RotatingFileHandler(
        arquivo_log,
        maxBytes=2_000_000,
        backupCount=3,
        encoding="utf-8",
    )
    handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(message)s"))

    app.logger.handlers.clear()
    app.logger.addHandler(handler)
    app.logger.setLevel(logging.INFO)
    app.logger.propagate = False


configurar_logs()


def preparar_banco():

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("banco_inicializacao_falha")
        return False

    try:
        inicializar_banco(conexao)
        app.logger.info("banco_inicializacao_sucesso")
        return True

    except Exception:
        app.logger.exception("banco_inicializacao_falha")
        return False

    finally:
        conexao.close()


# Extrai o token Bearer do header Authorization
def extrair_bearer_token():
    auth_header = request.headers.get("Authorization", "")

    if not auth_header.startswith("Bearer "):
        return None

    return auth_header.removeprefix("Bearer ").strip()


# 1.9 Validação de sessão ativa e não expirada
# 1.10 Validação de sessão não invalidada no logout
def autenticar_requisicao(conexao):
    token = extrair_bearer_token()

    if not token:
        return None, (jsonify({"error": "Token nao informado"}), 401)

    try:
        payload = validar_token(token)
    except jwt.ExpiredSignatureError:
        return None, (jsonify({"error": "Token expirado"}), 401)
    except jwt.InvalidTokenError as e:
        app.logger.warning(f"token_invalido: {str(e)}")
        return None, (jsonify({"error": f"Token invalido: {str(e)}"}), 401)

    token_jti = payload.get("jti")
    user_id = payload.get("sub")

    if not token_jti or not user_id:
        return None, (jsonify({"error": "Token invalido"}), 401)

    repo_sessao = SessionRepository(conexao)
    sessao = repo_sessao.buscar_ativa_por_jti(token_jti)

    if not sessao:
        return None, (jsonify({"error": "Sessao invalida ou encerrada"}), 401)

    repo_usuario = RepositorioUsuario(conexao)
    usuario = repo_usuario.buscar_por_id(int(user_id))

    if not usuario:
        return None, (jsonify({"error": "Usuario nao encontrado"}), 404)

    return {
        "token_jti": token_jti,
        "user": usuario,
    }, None


@app.post("/cadastrar")
# 1.11 Limite de tentativas no cadastro
@limiter.limit("5 per minute")
def cadastrar_usuario():

    dados = request.get_json(silent=True) or {}

    if any(not dados.get(campo) for campo in ("nome", "email", "senha")):
        app.logger.warning("cadastro_validacao_falha")
        return jsonify({"error": "Campos obrigatorios: nome, email e senha"}), 400

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("cadastro_erro_conexao")
        return jsonify(ERRO), 500

    try:

        # 1.1 Uso de hash criptográfico seguro para senhas
        # 1.3 Salt único por usuário é gerado automaticamente pelo bcrypt
        # 1.4 O valor salvo já contém hash + salt embutidos
        senha_hash = gerar_hash_senha(dados["senha"])

        usuario = Usuario(
            nome=dados["nome"],
            email=dados["email"],
            senha=senha_hash,
        )

        repositorio_usuario = RepositorioUsuario(conexao)
        usuario = repositorio_usuario.cadastrar(usuario)

        # 1.5 Autenticação de dois fatores implementada
        codigo = str(random.randint(100000, 999999))
        expira = datetime.now() + timedelta(minutes=10)

        auth_repo = AuthCodeRepository(conexao)
        auth_code = AuthCode(
            user_id=usuario.id,
            codigo=codigo,
            tipo="register",
            expira_em=expira,
        )

        auth_code = auth_repo.criar(auth_code)

        enviar_codigo(usuario.email, codigo)

        app.logger.info("cadastro_sucesso")

        return jsonify({
            "requires_2fa": True,
            "challenge_id": auth_code.id,
            "message": "Codigo enviado para o email"
        }), 201

    except Exception:
        app.logger.exception("cadastro_falha")
        return jsonify(ERRO), 500

    finally:
        conexao.close()


@app.post("/login")
# 1.11 Limite de tentativas no login
@limiter.limit("5 per minute")
def login():

    dados = request.get_json(silent=True) or {}

    if any(not dados.get(campo) for campo in ("email", "senha")):
        app.logger.warning("login_validacao_falha")
        return jsonify({"error": "Campos obrigatorios"}), 400

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("login_erro_conexao")
        return jsonify(ERRO), 500

    try:

        repo_usuario = RepositorioUsuario(conexao)
        usuario = repo_usuario.buscar_por_email(dados["email"])

        if not usuario:
            app.logger.warning("login_usuario_nao_encontrado")
            return jsonify({"error": "Usuario ou senha invalidos"}), 401

        # 1.1 Validação do hash seguro da senha
        if not verificar_senha(dados["senha"], usuario.senha):
            app.logger.warning("login_senha_invalida")
            return jsonify({"error": "Usuario ou senha invalidos"}), 401

        # 1.5 Geração do código 2FA após autenticação primária
        codigo = str(random.randint(100000, 999999))
        expira = datetime.now() + timedelta(minutes=10)

        auth_repo = AuthCodeRepository(conexao)
        auth_code = AuthCode(
            user_id=usuario.id,
            codigo=codigo,
            tipo="login",
            expira_em=expira,
        )

        auth_code = auth_repo.criar(auth_code)

        enviar_codigo(usuario.email, codigo)

        app.logger.info("login_codigo_enviado")

        return jsonify({
            "requires_2fa": True,
            "challenge_id": auth_code.id,
            "message": "Codigo enviado para o email"
        }), 200

    except Exception:
        app.logger.exception("login_falha")
        return jsonify(ERRO), 500

    finally:
        conexao.close()


@app.post("/verificar-codigo")
# 1.11 Limite de tentativas no 2FA
@limiter.limit("10 per minute")
def verificar_codigo():

    dados = request.get_json(silent=True) or {}

    challenge_id = dados.get("challenge_id")
    codigo = dados.get("codigo")

    if not challenge_id or not codigo:
        app.logger.warning("verificar_codigo_validacao_falha")
        return jsonify({"error": "challenge_id e codigo obrigatorios"}), 400

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("verificar_codigo_erro_conexao")
        return jsonify(ERRO), 500

    try:

        repo_codigo = AuthCodeRepository(conexao)
        resultado = repo_codigo.buscar_valido(challenge_id, codigo)

        # 1.6 Validação do 2FA após autenticação primária
        if not resultado:
            app.logger.warning("verificar_codigo_invalido_ou_expirado")
            return jsonify({"error": "Codigo invalido ou expirado"}), 400

        repo_codigo.marcar_usado(challenge_id)

        repo_usuario = RepositorioUsuario(conexao)
        usuario = repo_usuario.buscar_por_id(resultado["user_id"])

        if not usuario:
            app.logger.warning("verificar_codigo_usuario_nao_encontrado")
            return jsonify({"error": "Usuario nao encontrado"}), 404

        # 1.9 Criação de sessão com tempo de expiração via JWT
        token_data = gerar_token(usuario.id)

        repo_sessao = SessionRepository(conexao)
        repo_sessao.criar(
            Session(
                user_id=usuario.id,
                token_jti=token_data["token_jti"],
                expira_em=token_data["expira_em"],
            )
        )

        app.logger.info("verificar_codigo_sucesso")

        return jsonify({
            "ok": True,
            "message": "Autenticacao concluida",
            "token": token_data["token"],
            "expires_at": token_data["expira_em"].isoformat(),
        }), 200

    except Exception:
        app.logger.exception("verificar_codigo_falha")
        return jsonify(ERRO), 500

    finally:
        conexao.close()


@app.get("/me")
def me():

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("me_erro_conexao")
        return jsonify(ERRO), 500

    try:

        auth, erro = autenticar_requisicao(conexao)

        if erro:
            return erro

        usuario = auth["user"]

        app.logger.info("me_sucesso")

        return jsonify(usuario.para_json()), 200

    except Exception:
        app.logger.exception("me_falha")
        return jsonify(ERRO), 500

    finally:
        conexao.close()


@app.post("/logout")
def logout():

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("logout_erro_conexao")
        return jsonify(ERRO), 500

    try:

        auth, erro = autenticar_requisicao(conexao)

        if erro:
            return erro

        # 1.10 Invalidação de sessão no logout
        repo_sessao = SessionRepository(conexao)
        repo_sessao.invalidar_por_jti(auth["token_jti"])

        app.logger.info("logout_sucesso")

        return jsonify({
            "ok": True,
            "message": "Sessao encerrada com sucesso"
        }), 200

    except Exception:
        app.logger.exception("logout_falha")
        return jsonify(ERRO), 500

    finally:
        conexao.close()


@app.get("/usuarios")
def listar_usuarios():

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("listar_usuarios_erro_conexao")
        return jsonify(ERRO), 500

    try:

        repositorio = RepositorioUsuario(conexao)
        usuarios = repositorio.listar()

        app.logger.info("listar_usuarios_sucesso")
        return jsonify([u.para_json() for u in usuarios]), 200

    except Exception:
        app.logger.exception("listar_usuarios_falha")
        return jsonify(ERRO), 500

    finally:
        conexao.close()


if __name__ == "__main__":

    if not preparar_banco():
        raise RuntimeError("Nao foi possivel inicializar o banco MySQL")

    # 1.8 Evidência funcional: execução local do servidor com logs
    app.run(debug=True)