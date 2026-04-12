## Usado para realizar operações relacionadas aos códigos de autentição,
## como insere-los no banco de dados, buscar códigos válidos e marcar códigos
## já usados.

from datetime import datetime
from model.auth_code import AuthCode


class AuthCodeRepository:

    def __init__(self, conexao):
        ## Inicializa o repositório com a conexão do banco de dados
        self.conexao = conexao

    # Insere um novo código de autenticação no banco de dados
    def criar(self, auth_code: AuthCode):

        with self.conexao.cursor() as cursor:

            # Insere o auth_code com seus dados: ID do usuário, código, tipo (SMS/Email), e data de expiração
            cursor.execute(
                """
                INSERT INTO auth_codes (user_id, codigo, tipo, expira_em)
                VALUES (%s, %s, %s, %s)
                """,
                (
                    auth_code.user_id,
                    auth_code.codigo,
                    auth_code.tipo,
                    auth_code.expira_em,
                ),
            )

            self.conexao.commit()
            auth_code.id = cursor.lastrowid

        return auth_code

    # Busca apenas códigos válidos, não usados e não expirados
    def buscar_valido(self, challenge_id, codigo):

        with self.conexao.cursor(dictionary=True) as cursor:

            # Seleciona o código de autenticação se:
            # - ID corresponde (challenge_id)
            # - Código corresponde ao enviado
            # - Ainda não foi usado (usado=FALSE)
            # - Ainda não expirou (expira_em >= NOW())
            cursor.execute(
                """
                SELECT * FROM auth_codes
                WHERE id=%s
                AND codigo=%s
                AND usado=FALSE
                AND expira_em >= NOW()
                """,
                (challenge_id, codigo),
            )

            return cursor.fetchone()

    # Marca um código de autenticação como já utilizado
    def marcar_usado(self, challenge_id):

        with self.conexao.cursor() as cursor:

            # Atualiza o campo 'usado' para TRUE para evitar reuso do mesmo código
            cursor.execute(
                """
                UPDATE auth_codes
                SET usado = TRUE
                WHERE id=%s
                """,
                (challenge_id,),
            )

            self.conexao.commit()