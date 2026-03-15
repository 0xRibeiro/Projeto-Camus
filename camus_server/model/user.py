from dataclasses import dataclass
from typing import Optional


@dataclass
class Usuario:
    nome: str
    email: str
    senha: str
    id: Optional[int] = None

    def para_json(self) -> dict:
        return {
            "id": self.id,
            "nome": self.nome,
            "email": self.email,
        }


	

    

	