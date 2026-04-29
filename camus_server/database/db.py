## Arquivo responsável por criar a conexão com o banco de dados,
## utilizando as variáveis de ambiente do .env.
## A conexão é feita com o driver do psycopg2 e as tabelas são criadas
## caso ainda não existam no banco. Há tratamento de erros se
## a conexão falhar.

import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")


def criar_conexao():
    try:
        url = DATABASE_URL
        if url and url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql://", 1)
        conexao = psycopg2.connect(url)
    except psycopg2.Error:
        return None
    return conexao


def inicializar_banco(conexao):

    tabela_users = """
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        senha VARCHAR(255) NOT NULL
    )
    """

    tabela_auth_codes = """
    CREATE TABLE IF NOT EXISTS auth_codes (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        codigo VARCHAR(500) NOT NULL,
        tipo VARCHAR(20) NOT NULL,
        expira_em TIMESTAMP NOT NULL,
        usado BOOLEAN DEFAULT FALSE,
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )
    """

    tabela_sessions = """
    CREATE TABLE IF NOT EXISTS sessions (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        token_jti VARCHAR(64) NOT NULL UNIQUE,
        expira_em TIMESTAMP NOT NULL,
        invalidada BOOLEAN DEFAULT FALSE,
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )
    """

    tabela_recovery_sessions = """
    CREATE TABLE IF NOT EXISTS recovery_sessions (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        token_jti VARCHAR(64) NOT NULL UNIQUE,
        expira_em TIMESTAMP NOT NULL,
        invalidada BOOLEAN DEFAULT FALSE,
        criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )
    """

    with conexao.cursor() as cursor:
        cursor.execute(tabela_users)
        cursor.execute(tabela_auth_codes)
        cursor.execute(tabela_sessions)
        cursor.execute(tabela_recovery_sessions)

    conexao.commit()
