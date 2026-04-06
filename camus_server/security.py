import bcrypt
from cryptography.fernet import Fernet
import os
import base64
import hashlib
from dotenv import load_dotenv

# Carrega variáveis do .env
load_dotenv()

# configuração de segurança
COST_FACTOR = 12  

"""
Justificativa: O fator de custo 12 proporciona equilíbrio entre
segurança e desempenho, conforme recomendado pela OWASP.
"""
# chave de criptografia AES
SECRET_KEY = os.getenv("SECRET_KEY")

if not SECRET_KEY:
    raise ValueError("A SECRET_KEY não foi definida no ambiente!")

def gerar_chave_fernet(secret: str) -> bytes:
    """

    Converte a chave em formato válido para o Fernet-AES.
    """
    hash_sha256 = hashlib.sha256(secret.encode()).digest()
    return base64.urlsafe_b64encode(hash_sha256)

CHAVE_SECRETA = gerar_chave_fernet(SECRET_KEY)

fernet = Fernet(CHAVE_SECRETA)

# função da senha bycript

def gerar_hash_senha(senha: str) -> str:
    """
    Gera hash seguro da senha usando bcrypt.
    """
    salt = bcrypt.gensalt(rounds=COST_FACTOR)
    senha_hash = bcrypt.hashpw(senha.encode("utf-8"), salt)
    return senha_hash.decode("utf-8")


def verificar_senha(senha: str, senha_hash: str) -> bool:
    """
    Verifica se a senha corresponde ao hash.
    """
    return bcrypt.checkpw(
        senha.encode("utf-8"),
        senha_hash.encode("utf-8")
    )




# função da criptogranfia AES
def criptografar_dado(dado: str) -> str:
    """ Criptografa dados sensíveis utilizando AES.
    """
    return fernet.encrypt(dado.encode()).decode()


def descriptografar_dado(dado_criptografado: str) -> str:
    """Descriptografa dados previamente criptografados
    """
    return fernet.decrypt(dado_criptografado.encode()).decode()