## Lida com a geração dos tokens utilizados no sistema. Atualmente existem
## tokens de autenticação e recuperação de senha, ambos com expiração configurada

import os
import uuid
import jwt
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv

load_dotenv()

JWT_SECRET = os.getenv("JWT_SECRET")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRE_DAYS = int(os.getenv("JWT_EXPIRE_DAYS", "7"))


def gerar_token(user_id: int):

    agora = datetime.now(timezone.utc)
    expira_em = agora + timedelta(days=JWT_EXPIRE_DAYS)

    ## uuid usado para identificar o token.
    token_jti = str(uuid.uuid4())

    payload = {
        "sub": str(user_id),
        "jti": token_jti,
        "exp": expira_em,
    }

    # 1.9 Token com expiração configurada
    # 2.3 Token com tempo de expiração
    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

    return {
        "token": token,
        "token_jti": token_jti,
        "expira_em": expira_em,
    }
    


def gerar_token_recuperacao(user_id: int):

    agora = datetime.now(timezone.utc)
    expira_em = agora + timedelta(minutes=15)

    token_jti = str(uuid.uuid4())

    payload = {
        "sub": str(user_id),
        "jti": token_jti,
        "type": "recovery",
        "exp": expira_em,
    }

    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

    return {
        "token": token,
        "token_jti": token_jti,
        "expira_em": expira_em,
    }


## A validação acontece verificando a assinatura do token, a expiração e os campos obrigatórios.
def validar_token(token: str):

    return jwt.decode(
        token,
        JWT_SECRET,
        algorithms=[JWT_ALGORITHM],
        options={
            "require": ["exp", "sub", "jti"]
        },
        leeway=10,
    )