from model.session import Session


class SessionRepository:

    def __init__(self, conexao):
        self.conexao = conexao

    def criar(self, sessao: Session) -> Session:
        with self.conexao.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO sessions (user_id, token_jti, expira_em, invalidada)
                VALUES (%s, %s, %s, %s)
                """,
                (
                    sessao.user_id,
                    sessao.token_jti,
                    sessao.expira_em,
                    sessao.invalidada,
                ),
            )
            self.conexao.commit()
            sessao.id = cursor.lastrowid
        return sessao

    def buscar_ativa_por_jti(self, token_jti: str):
        with self.conexao.cursor(dictionary=True) as cursor:
            cursor.execute(
                """
                SELECT * FROM sessions
                WHERE token_jti = %s
                AND invalidada = FALSE
                AND expira_em >= NOW()
                LIMIT 1
                """,
                (token_jti,),
            )
            return cursor.fetchone()

    def invalidar_por_jti(self, token_jti: str):
        with self.conexao.cursor() as cursor:
            cursor.execute(
                """
                UPDATE sessions
                SET invalidada = TRUE
                WHERE token_jti = %s
                """,
                (token_jti,),
            )
            self.conexao.commit()