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