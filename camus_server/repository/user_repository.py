from model.user import Usuario

class RepositorioUsuario:
    def __init__(self, conexao):
        self.conexao = conexao

    def cadastrar(self, usuario: Usuario) -> Usuario:
        with self.conexao.cursor() as cursor:
            cursor.execute(
                "INSERT INTO users (nome, email, senha) VALUES (%s, %s, %s)",
                (usuario.nome, usuario.email, usuario.senha),
            )
            self.conexao.commit()
            usuario.id = cursor.lastrowid
        return usuario
