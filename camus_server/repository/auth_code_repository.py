from datetime import datetime
from model.auth_code import AuthCode


class AuthCodeRepository:

    def __init__(self, conexao):
        self.conexao = conexao

    def criar(self, auth_code: AuthCode):

        with self.conexao.cursor() as cursor:

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

    def buscar_valido(self, challenge_id, codigo):

        with self.conexao.cursor(dictionary=True) as cursor:

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

    def marcar_usado(self, challenge_id):

        with self.conexao.cursor() as cursor:

            cursor.execute(
                """
                UPDATE auth_codes
                SET usado = TRUE
                WHERE id=%s
                """,
                (challenge_id,),
            )

            self.conexao.commit()