## Classe responsável por criar o código de autenticação temporário 
## utilizado em processos como recuperação de senha e verificação de email.

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class AuthCode:
    user_id: int
    codigo: str
    tipo: str
    expira_em: datetime
    usado: bool = False
    id: Optional[int] = None