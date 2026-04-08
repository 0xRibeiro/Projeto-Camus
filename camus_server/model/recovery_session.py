## Cria uma sessão temporária para recuperação de senha,
## associada a um usuário e um token JWT específico. A
## sessão expira após um período definido e é invalidada após o uso.

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class RecoverySession:
    user_id: int
    token_jti: str
    expira_em: datetime
    invalidada: bool = False
    id: Optional[int] = None