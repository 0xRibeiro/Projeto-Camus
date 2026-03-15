from flask import Flask, jsonify, request
from database.db import criar_conexao, inicializar_banco
from model.user import Usuario
from repository.user_repository import RepositorioUsuario

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
        return (
            jsonify({"error": "Campos obrigatorios: nome, email e senha"}),
            400,
        )

    conexao = criar_conexao()
    if not conexao:
        return jsonify(ERRO), 500

    try:
        usuario = Usuario(
            nome=dados["nome"],
            email=dados["email"],
            senha=dados["senha"],
        )
        repositorio = RepositorioUsuario(conexao)
        usuario = repositorio.cadastrar(usuario)
        return jsonify(usuario.para_json()), 201
    except Exception:
        return jsonify(ERRO), 500
    finally:
        conexao.close()

if __name__ == "__main__":
    if not preparar_banco():
        raise RuntimeError("Nao foi possivel inicializar o banco MySQL")
    app.run(debug=True)