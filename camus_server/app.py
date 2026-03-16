import random

from flask import Flask, jsonify, request
from database.db import criar_conexao, inicializar_banco
from model.user import Usuario
from repository.user_repository import RepositorioUsuario
from security import gerar_hash_senha

from model.auth_code import AuthCode
from repository.auth_code_repository import AuthCodeRepository

from service.email_service import enviar_codigo

from datetime import datetime, timedelta

from dotenv import load_dotenv
load_dotenv()



app = Flask(__name__)

ERRO = {"error": "Erro interno ao processar a solicitacao"}


def preparar_banco():

    conexao = criar_conexao()

    if not conexao:
        return False

    try:
        inicializar_banco(conexao)
        return True

    except Exception:
        return False

    finally:
        conexao.close()


@app.post("/cadastrar")
def cadastrar_usuario():

    dados = request.get_json(silent=True) or {}

    if any(not dados.get(campo) for campo in ("nome", "email", "senha")):
        return jsonify({"error": "Campos obrigatorios"}), 400

    conexao = criar_conexao()

    if not conexao:
        return jsonify(ERRO), 500

    try:

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

        return jsonify({
            "requires_2fa": True,
            "challenge_id": auth_code.id,
            "message": "Codigo enviado para o email"
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        conexao.close()


@app.post("/login")
def login():

    dados = request.get_json(silent=True) or {}

    if any(not dados.get(campo) for campo in ("email", "senha")):
        return jsonify({"error": "Campos obrigatorios"}), 400

    conexao = criar_conexao()

    if not conexao:
        return jsonify(ERRO), 500

    try:

        repo_usuario = RepositorioUsuario(conexao)

        usuario = repo_usuario.buscar_por_email(dados["email"])

        if not usuario:
            return jsonify({"error": "Usuario ou senha invalidos"}), 401

        if usuario.senha != dados["senha"]:
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

        return jsonify({
            "requires_2fa": True,
            "challenge_id": auth_code.id,
            "message": "Codigo enviado para o email"
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        conexao.close()


@app.post("/verificar-codigo")
def verificar_codigo():

    dados = request.get_json(silent=True) or {}

    challenge_id = dados.get("challenge_id")
    codigo = dados.get("codigo")

    if not challenge_id or not codigo:
        return jsonify({"error": "challenge_id e codigo obrigatorios"}), 400

    conexao = criar_conexao()

    if not conexao:
        return jsonify(ERRO), 500

    try:

        repo = AuthCodeRepository(conexao)

        resultado = repo.buscar_valido(challenge_id, codigo)

        if not resultado:
            return jsonify({"error": "Codigo invalido ou expirado"}), 400

        repo.marcar_usado(challenge_id)

        return jsonify({
            "ok": True,
            "message": "Autenticacao concluida"
        })

    except Exception:
        return jsonify(ERRO), 500

    finally:
        conexao.close()


@app.get("/usuarios")
def listar_usuarios():

    conexao = criar_conexao()

    if not conexao:
        return jsonify(ERRO), 500

    try:

        repositorio = RepositorioUsuario(conexao)

        usuarios = repositorio.listar()

        return jsonify([u.para_json() for u in usuarios])

    except Exception:
        return jsonify(ERRO), 500

    finally:
        conexao.close()


if __name__ == "__main__":

    if not preparar_banco():
        raise RuntimeError("Nao foi possivel inicializar o banco MySQL")

    app.run(debug=True)