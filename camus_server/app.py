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

from model.recovery_session import RecoverySession
from repository.recovery_session_repository import RecoverySessionRepository
from service.token_service import gerar_token, validar_token, gerar_token_recuperacao

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
           # 2.7 Registro de sucesso/falha do processo
        app.logger.error("verificar_codigo_erro_conexao")
        return jsonify(ERRO), 500

    try:

        repo_codigo = AuthCodeRepository(conexao)
        resultado = repo_codigo.buscar_valido(challenge_id, codigo)

        # 1.6 Validação do 2FA após autenticação primária
        if not resultado:
               # 2.7 Registro de sucesso/falha do processo
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

        # 2.7 Registro de sucesso/falha do processo
        app.logger.info("verificar_codigo_sucesso")

        return jsonify({
            "ok": True,
            "message": "Autenticacao concluida",
            "token": token_data["token"],
            "expires_at": token_data["expira_em"].isoformat(),
        }), 200

    except Exception:
           # 2.7 Registro de sucesso/falha do processo
        app.logger.exception("verificar_codigo_falha")
        return jsonify(ERRO), 500

    finally:
        conexao.close()
        
        
@app.post("/verificar-codigo-recuperacao")
@limiter.limit("5 per minute")
def verificar_codigo_recuperacao():

    dados = request.get_json(silent=True) or {}
    challenge_id = dados.get("challenge_id")
    codigo = dados.get("codigo")

    if not challenge_id or not codigo:
        return jsonify({"error": "challenge_id e codigo obrigatorios"}), 400

    conexao = criar_conexao()

    try:
        repo_codigo = AuthCodeRepository(conexao)

        resultado = repo_codigo.buscar_valido(challenge_id, codigo)

        if not resultado or resultado["tipo"] != "password_reset":
            return jsonify({"error": "Codigo invalido"}), 400

        repo_codigo.marcar_usado(challenge_id)

        user_id = resultado["user_id"]

        token_data = gerar_token_recuperacao(user_id)

        repo_recovery = RecoverySessionRepository(conexao)

        repo_recovery.criar(
            RecoverySession(
                user_id=user_id,
                token_jti=token_data["token_jti"],
                expira_em=token_data["expira_em"],
            )
        )

        return jsonify({
            "ok": True,
            "token": token_data["token"],
        }), 200

    finally:
        conexao.close()


@app.post("/recuperar-senha")
@limiter.limit("5 per minute")
def solicitar_recuperacao_senha():

    dados = request.get_json(silent=True) or {}
    email = (dados.get("email") or "").strip().lower()

    # 2.6 Registro de solicitação de recuperação em log
    app.logger.info("recuperar_senha_requisicao_recebida")

    if not email:
        app.logger.warning("recuperar_senha_validacao_falha")
        return jsonify({"error": "Campo obrigatorio: email"}), 400

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("recuperar_senha_erro_conexao")
        return jsonify(ERRO), 500

    try:
        repo_usuario = RepositorioUsuario(conexao)
        usuario = repo_usuario.buscar_por_email(email)

        # resposta generica para nao revelar se o email existe
        if not usuario:
            app.logger.info("recuperar_senha_email_nao_encontrado")
            return jsonify({
                "ok": True,
                "message": "Se o e-mail existir, as instrucoes foram enviadas"
            }), 200

        codigo = str(random.randint(100000, 999999))
        expira = datetime.now() + timedelta(minutes=10)

        # 2.2 Token criptograficamente seguro
        repo_codigo = AuthCodeRepository(conexao)
        auth_code = AuthCode(
            user_id=usuario.id,
            codigo=codigo,
            tipo="password_reset",
            expira_em=expira,
        )

        auth_code = repo_codigo.criar(auth_code)

        enviar_codigo(usuario.email, codigo)
        
        # 2.7 Registro de sucesso/falha do processo
        app.logger.info("recuperar_senha_sucesso")

        return jsonify({
            "ok": True,
            "message": "Se o e-mail existir, as instrucoes foram enviadas",
            "challenge_id": auth_code.id,
        }), 200

    # 2.7 Registro de sucesso/falha do processo
    except Exception:
        app.logger.exception("recuperar_senha_falha")
        return jsonify(ERRO), 500

    finally:
        conexao.close()

@app.post("/redefinir-senha")
@limiter.limit("5 per minute")
def redefinir_senha():

    dados = request.get_json(silent=True) or {}
    token = (dados.get("token") or "").strip()
    nova_senha = dados.get("nova_senha") or ""

    # 2.6 Registro de solicitação de recuperação em log
    app.logger.info("redefinir_senha_requisicao_recebida")

    if not token or not nova_senha:
        app.logger.warning("redefinir_senha_validacao_falha")
        return jsonify({"error": "Campos obrigatorios: token e nova_senha"}), 400

    if len(nova_senha) < 8:
        app.logger.warning("redefinir_senha_senha_fraca")
        return jsonify({"error": "A nova senha deve ter ao menos 8 caracteres"}), 400

    try:
        payload = validar_token(token)
        user_id = int(payload.get("sub"))
        token_jti = payload.get("jti")
        token_type = payload.get("type")

        if token_type != "recovery":
            app.logger.warning("redefinir_senha_tipo_token_invalido")
            return jsonify({"error": "Token invalido"}), 401

    # 2.5 Falha correta para token expirado
    except jwt.ExpiredSignatureError:
        app.logger.warning("redefinir_senha_token_expirado")
        return jsonify({"error": "Token expirado"}), 401
    except (jwt.InvalidTokenError, TypeError, ValueError) as e:
        app.logger.warning(f"redefinir_senha_token_invalido: {str(e)}")
        return jsonify({"error": "Token invalido"}), 401

    conexao = criar_conexao()

    if not conexao:
        app.logger.error("redefinir_senha_erro_conexao")
        return jsonify(ERRO), 500

    try:
        repo_recovery = RecoverySessionRepository(conexao)
        recovery_session = repo_recovery.buscar_ativa_por_jti(token_jti)

        if not recovery_session:
            app.logger.warning("redefinir_senha_recovery_session_invalida")
            return jsonify({"error": "Sessao de recuperacao invalida ou expirada"}), 401

        repo_usuario = RepositorioUsuario(conexao)
        usuario = repo_usuario.buscar_por_id(user_id)

        if not usuario:
            app.logger.warning("redefinir_senha_usuario_nao_encontrado")
            return jsonify({"error": "Usuario nao encontrado"}), 404

        senha_hash = gerar_hash_senha(nova_senha)
        repo_usuario.atualizar_senha(usuario.id, senha_hash)

        # invalida a sessao de recuperacao usada
        # 2.4 Token invalidado após uso 
        repo_recovery.invalidar_por_jti(token_jti)

        # invalida outras sessoes de recuperacao do mesmo usuario
        repo_recovery.invalidar_todas_por_usuario(usuario.id)

        # invalida as sessões existentes após trocar a senha
        repo_sessao = SessionRepository(conexao)
        repo_sessao.invalidar_todas_por_usuario(usuario.id)

        app.logger.info("redefinir_senha_sucesso")

        return jsonify({
            "ok": True,
            "message": "Senha redefinida com sucesso"
        }), 200

    except Exception:
        app.logger.exception("redefinir_senha_falha")
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
    app.run(debug=True, ssl_context=('cert.pem', 'key.pem'))