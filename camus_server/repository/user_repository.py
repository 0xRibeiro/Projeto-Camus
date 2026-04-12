## Realiza as operações do do usuário no banco de dados,
## como cadastrar, buscar e atualizar senha.

from model.user import Usuario


class RepositorioUsuario:
    ## Conexão com o bd
    def __init__(self, conexao):
        self.conexao = conexao

    ## Esse bloco de código possui metódos que compoem o CRUD do usuário.

    def cadastrar(self, usuario: Usuario) -> Usuario:
        with self.conexao.cursor() as cursor:
            # 1.4 Armazenamento do hash já gerado da senha
            cursor.execute(
                "INSERT INTO users (nome, email, senha) VALUES (%s, %s, %s)",
                (usuario.nome, usuario.email, usuario.senha),
            )
            self.conexao.commit()
            usuario.id = cursor.lastrowid
        return usuario

    def listar(self) -> list[Usuario]:
        with self.conexao.cursor() as cursor:
            cursor.execute("SELECT id, nome, email, senha FROM users")
            return [
                Usuario(id=row[0], nome=row[1], email=row[2], senha=row[3])
                for row in cursor.fetchall()
            ]
    
    def buscar_por_email(self, email: str) -> Usuario | None:
        with self.conexao.cursor() as cursor:
            cursor.execute(
                "SELECT id, nome, email, senha FROM users WHERE email = %s",
                (email,),
            )
            row = cursor.fetchone()

            if not row:
                return None

            return Usuario(
                id=row[0],
                nome=row[1],
                email=row[2],
                senha=row[3],
            )

    def buscar_por_id(self, user_id: int) -> Usuario | None:
        with self.conexao.cursor() as cursor:
            cursor.execute(
                "SELECT id, nome, email, senha FROM users WHERE id = %s",
                (user_id,),
            )
            row = cursor.fetchone()

            if not row:
                return None

            return Usuario(
                id=row[0],
                nome=row[1],
                email=row[2],
                senha=row[3],
            )

    def atualizar_senha(self, user_id: int, senha_hash: str):
        with self.conexao.cursor() as cursor:
            cursor.execute(
                "UPDATE users SET senha = %s WHERE id = %s",
                (senha_hash, user_id),
            )
            self.conexao.commit()