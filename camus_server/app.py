import logging
import random
from pathlib import Path
from logging.handlers import RotatingFileHandler
from datetime import datetime, timedelta

from flask import Flask, jsonify, request
from dotenv import load_dotenv
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

from database.db import criar_conexao, inicializar_banco
from model.user import Usuario
from repository.user_repository import RepositorioUsuario
from security import gerar_hash_senha, verificar_senha

from model.auth_code import AuthCode
from repository.auth_code_repository import AuthCodeRepository
from service.email_service import enviar_codigo

load_dotenv()

app = Flask(__name__)

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


@app.post("/cadastrar")
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

        senha_hash = gerar_hash_senha(dados["senha"])

        usuario = Usuario(
            nome=dados["nome"],
            email=dados["email"],
            senha=senha_hash,
        )

        repositorio_usuario = RepositorioUsuario(conexao)
        usuario = repositorio_usuario.cadastrar(usuario)

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

        if not verificar_senha(dados["senha"], usuario.senha):
            app.logger.warning("login_senha_invalida")
            return jsonify({"error": "Usuario ou senha invalidos"}), 401

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

        repo = AuthCodeRepository(conexao)
        resultado = repo.buscar_valido(challenge_id, codigo)

        if not resultado:
            app.logger.warning("verificar_codigo_invalido_ou_expirado")
            return jsonify({"error": "Codigo invalido ou expirado"}), 400

        repo.marcar_usado(challenge_id)

        repo_usuario = RepositorioUsuario(conexao)
        usuario = repo_usuario.buscar_por_id(resultado["user_id"])
        
        if not usuario:
            app.logger.warning("verificar_codigo_usuario_nao_encontrado")
            return jsonify({"error": "Usuario nao encontrado"}), 404
        
        app.logger.info("verificar_codigo_sucesso")
        
        return jsonify({
            "ok": True,
            "message": "Autenticacao concluida",
            "user": usuario.para_json()
        }), 200

    except Exception:
        app.logger.exception("verificar_codigo_falha")
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

    app.run(debug=True)