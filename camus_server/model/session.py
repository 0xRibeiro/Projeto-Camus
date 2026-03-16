from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class Session:
    user_id: int
    token_jti: str
    expira_em: datetime
    invalidada: bool = False
    id: Optional[int] = None