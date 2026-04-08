## Cria o modelo do usuário no sistema, com os campos necessários
## para seu cadastro e um id de autenticação. Futuramente podemos
## ampliar esse modelo quando o sistema tiver mais funcionalidades.
## Por enquanto ele será simples.

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


	

    

	