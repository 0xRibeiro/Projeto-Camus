## Responsável por enviar o código de verificação 2FA por email via Brevo API.
## Usa HTTP em vez de SMTP pois provedores cloud gratuitos bloqueiam conexões SMTP de saída.


import os
import requests

EMAIL_REMETENTE = os.getenv("EMAIL_REMETENTE")
BREVO_API_KEY = os.getenv("BREVO_API_KEY")


def enviar_codigo(email_destino, codigo):

    requests.post(
        "https://api.brevo.com/v3/smtp/email",
        headers={
            "api-key": BREVO_API_KEY,
            "Content-Type": "application/json",
        },
        json={
            "sender": {"email": EMAIL_REMETENTE},
            "to": [{"email": email_destino}],
            "subject": "Seu codigo de verificacao",
            "textContent": (
                f"Seu codigo de verificacao é:\n\n"
                f"{codigo}\n\n"
                f"Este codigo expira em 10 minutos."
            ),
        },
    )
