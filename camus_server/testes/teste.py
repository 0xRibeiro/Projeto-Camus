## Arquivo usado para testar as rotas da aplicação utilizando pytest,
## simulando as conexões com o banco de dados e o envio de emails para garantir
## que as funcionalidades estão funcionando corretamente.

import sys
from pathlib import Path

## configura o caminho da pasta raiz do projeto pare ter os módulos corretos.
pasta_raiz = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(pasta_raiz))

import pytest
import app
from unittest.mock import MagicMock, patch
from model.user import Usuario

## simula o uso de https.
HTTPS = "https://localhost"

## Linhas 24-37 criam as fixtures para os testes, que servem para injetar
## certas configurações automaticamente nos testes abaixo, como simular a falta
## de conexão com o banco de dados.

@pytest.fixture
def client():
    app.app.testing = True
    return app.app.test_client()

@pytest.fixture
def mock_conexao():
    with patch.object(app, "criar_conexao", new=lambda: MagicMock()):
        yield

@pytest.fixture
def sem_conexao():
    with patch.object(app, "criar_conexao", new=lambda: None):
        yield

## os testes abaixo verificam o comportamento de certas rotas em caso de sucesso e
## falha, garantindo que os retornos estão corretos para cada situação

def test_cadastro_sucesso(client, mock_conexao):
    repo = MagicMock()
    repo_auth = MagicMock()
    repo.cadastrar.return_value = Usuario(id=1, nome="Ana", email="ana@email.com", senha="123")
    repo_auth.criar.return_value = MagicMock(id=123)
    with patch.object(app, "RepositorioUsuario", return_value=repo), \
        patch.object(app, "AuthCodeRepository", return_value=repo_auth), \
        patch.object(app, "enviar_codigo"):
        resp = client.post(
            "/cadastrar",
            json={"nome": "Ana", "email": "ana@email.com", "senha": "123"},
            base_url=HTTPS,
        )
    assert resp.status_code == 201
    dados = resp.get_json()
    assert dados["requires_2fa"] is True
    assert dados["challenge_id"] == 123

def test_cadastro_campos_faltando_retorna_400(client):
    assert client.post(
        "/cadastrar",
        json={"email": "ana@email.com", "senha": "123"},
        base_url=HTTPS,
    ).status_code == 400
    assert client.post(
        "/cadastrar",
        json={"nome": "Ana", "senha": "123"},
        base_url=HTTPS,
    ).status_code == 400
    assert client.post(
        "/cadastrar",
        json={"nome": "Ana", "email": "ana@email.com"},
        base_url=HTTPS,
    ).status_code == 400

def test_cadastro_sem_conexao_retorna_500(client, sem_conexao):
    assert client.post(
        "/cadastrar",
        json={"nome": "Ana", "email": "ana@email.com", "senha": "123"},
        base_url=HTTPS,
    ).status_code == 500

def test_listar_sucesso(client, mock_conexao):
    repo = MagicMock()
    repo.listar.return_value = [
        Usuario(id=1, nome="Ana", email="ana@email.com", senha="123"),
        Usuario(id=2, nome="Bob", email="bob@email.com", senha="456"),
    ]
    with patch.object(app, "RepositorioUsuario", return_value=repo):
        resp = client.get("/usuarios", base_url=HTTPS)
    assert resp.status_code == 200
    assert len(resp.get_json()) == 2

def test_listar_sem_conexao_retorna_500(client, sem_conexao):
    assert client.get("/usuarios", base_url=HTTPS).status_code == 500

def test_listar_erro_repositorio_retorna_500(client, mock_conexao):
    repo = MagicMock()
    repo.listar.side_effect = Exception("erro no banco")
    with patch.object(app, "RepositorioUsuario", return_value=repo):
        assert client.get("/usuarios", base_url=HTTPS).status_code == 500
