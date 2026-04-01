from mysql.connector import Error, connect
from dotenv import load_dotenv
import os 
load_dotenv()


IP = os.getenv("DB_IP")
PORTA = int(os.getenv("DB_PORT"))
USUARIO = os.getenv("DB_USER")
SENHA = os.getenv("DB_PASSWORD")
NOME = os.getenv("DB_NAME")


def criar_conexao():
    conexao = None
    try:
        conexao = connect(
            host=IP,
            user=USUARIO,
            password=SENHA,
            database=NOME,
            port=PORTA,
        )
    except Error:
        return None
    return conexao


def inicializar_banco(conexao):

    tabela_users = """
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        senha VARCHAR(255) NOT NULL
    )
    """

    tabela_auth_codes = """
    CREATE TABLE IF NOT EXISTS auth_codes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        codigo VARCHAR(6) NOT NULL,
        tipo VARCHAR(20) NOT NULL,
        expira_em DATETIME NOT NULL,
        usado BOOLEAN DEFAULT FALSE,
        criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )
    """

    tabela_sessions = """
    CREATE TABLE IF NOT EXISTS sessions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        token_jti VARCHAR(64) NOT NULL UNIQUE,
        expira_em DATETIME NOT NULL,
        invalidada BOOLEAN DEFAULT FALSE,
        criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )
    """
    
    tabela_recovery_sessions = """
    CREATE TABLE IF NOT EXISTS recovery_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token_jti VARCHAR(64) NOT NULL UNIQUE,
    expira_em DATETIME NOT NULL,
    invalidada BOOLEAN DEFAULT FALSE,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
    )
    """

    with conexao.cursor() as cursor:
        cursor.execute(tabela_users)
        cursor.execute(tabela_auth_codes)
        cursor.execute(tabela_sessions)
        cursor.execute(tabela_recovery_sessions)

    conexao.commit()