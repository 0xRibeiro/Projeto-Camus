import sys
from pathlib import Path

pasta_raiz = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(pasta_raiz))

import pytest
import app as app_module
from app import app
from unittest.mock import MagicMock, patch
from model.user import Usuario

@pytest.fixture
def client():
    app.testing = True
    return app.test_client()

@pytest.fixture
def mock_conexao():
    with patch.object(app_module, "criar_conexao", new=lambda: MagicMock()):
        yield

@pytest.fixture
def sem_conexao():
    with patch.object(app_module, "criar_conexao", new=lambda: None):
        yield

def test_cadastro_sucesso(client, mock_conexao):
    repo = MagicMock()
    repo.cadastrar.return_value = Usuario(id=1, nome="Ana", email="ana@email.com", senha="123")
    with patch.object(app_module, "RepositorioUsuario", return_value=repo):
        resp = client.post("/cadastrar", json={"nome": "Ana", "email": "ana@email.com", "senha": "123"})
    assert resp.status_code == 201
    assert resp.get_json()["email"] == "ana@email.com"

def test_cadastro_campos_faltando_retorna_400(client):
    assert client.post("/cadastrar", json={"email": "ana@email.com", "senha": "123"}).status_code == 400
    assert client.post("/cadastrar", json={"nome": "Ana", "senha": "123"}).status_code == 400
    assert client.post("/cadastrar", json={"nome": "Ana", "email": "ana@email.com"}).status_code == 400

def test_cadastro_sem_conexao_retorna_500(client, sem_conexao):
    assert client.post("/cadastrar", json={"nome": "Ana", "email": "ana@email.com", "senha": "123"}).status_code == 500

def test_listar_sucesso(client, mock_conexao):
    repo = MagicMock()
    repo.listar.return_value = [
        Usuario(id=1, nome="Ana", email="ana@email.com", senha="123"),
        Usuario(id=2, nome="Bob", email="bob@email.com", senha="456"),
    ]
    with patch.object(app_module, "RepositorioUsuario", return_value=repo):
        resp = client.get("/usuarios")
    assert resp.status_code == 200
    assert len(resp.get_json()) == 2

def test_listar_sem_conexao_retorna_500(client, sem_conexao):
    assert client.get("/usuarios").status_code == 500

def test_listar_erro_repositorio_retorna_500(client, mock_conexao):
    repo = MagicMock()
    repo.listar.side_effect = Exception("erro no banco")
    with patch.object(app_module, "RepositorioUsuario", return_value=repo):
        assert client.get("/usuarios").status_code == 500
