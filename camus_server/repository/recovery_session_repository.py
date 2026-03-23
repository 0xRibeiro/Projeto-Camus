from model.recovery_session import RecoverySession


class RecoverySessionRepository:

    def __init__(self, conexao):
        self.conexao = conexao

    def criar(self, sessao: RecoverySession) -> RecoverySession:
        with self.conexao.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO recovery_sessions (user_id, token_jti, expira_em, invalidada)
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
                SELECT * FROM recovery_sessions
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
                UPDATE recovery_sessions
                SET invalidada = TRUE
                WHERE token_jti = %s
                """,
                (token_jti,),
            )
            self.conexao.commit()

    def invalidar_todas_por_usuario(self, user_id: int):
        with self.conexao.cursor() as cursor:
            cursor.execute(
                """
                UPDATE recovery_sessions
                SET invalidada = TRUE
                WHERE user_id = %s
                """,
                (user_id,),
            )
            self.conexao.commit()