from mysql.connector import Error, connect


IP = "127.0.0.1"
PORTA = 3306
USUARIO = "root"
SENHA = ""
NOME = "camus"


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
    query = """
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        senha VARCHAR(255) NOT NULL
    )
    """

    with conexao.cursor() as cursor:
        cursor.execute(query)
    conexao.commit()