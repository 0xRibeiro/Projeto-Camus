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

    token_jti = str(uuid.uuid4())

    payload = {
        "sub": str(user_id),
        "jti": token_jti,
        "exp": expira_em,
    }

    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

    return {
        "token": token,
        "token_jti": token_jti,
        "expira_em": expira_em,
    }


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