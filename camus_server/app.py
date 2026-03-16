import logging
from pathlib import Path
from logging.handlers import RotatingFileHandler
from flask import Flask, jsonify, request
from database.db import criar_conexao, inicializar_banco
from model.user import Usuario
from repository.user_repository import RepositorioUsuario

app = Flask(__name__)

ERRO = {"error": "Erro interno ao processar a solicitacao"}


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
def cadastrar_usuario():
    dados = request.get_json(silent=True) or {}
    if any(not dados.get(campo) for campo in ("nome", "email", "senha")):
        app.logger.warning("cadastro_validacao_falha")
        return (
            jsonify({"error": "Campos obrigatorios: nome, email e senha"}),
            400,
        )

    conexao = criar_conexao()
    if not conexao:
        app.logger.error("cadastro_erro_conexao")
        return jsonify(ERRO), 500

    try:
        usuario = Usuario(
            nome=dados["nome"],
            email=dados["email"],
            senha=dados["senha"],
        )
        repositorio = RepositorioUsuario(conexao)
        usuario = repositorio.cadastrar(usuario)
        app.logger.info("cadastro_sucesso")
        return jsonify(usuario.para_json()), 201
    except Exception:
        app.logger.exception("cadastro_falha")
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