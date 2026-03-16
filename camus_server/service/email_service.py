import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os


EMAIL_REMETENTE = os.getenv("EMAIL_REMETENTE")
EMAIL_SENHA = os.getenv("EMAIL_SENHA")
SMTP_SERVIDOR = "smtp.gmail.com"
SMTP_PORTA = 587


def enviar_codigo(email_destino, codigo):

    mensagem = MIMEMultipart()

    mensagem["From"] = EMAIL_REMETENTE
    mensagem["To"] = email_destino
    mensagem["Subject"] = "Seu codigo de verificacao"

    # 1.5 Envio do código 2FA por email
    corpo = f"""
Seu codigo de verificacao é:

{codigo}

Este codigo expira em 10 minutos.
"""

    mensagem.attach(MIMEText(corpo, "plain"))

    servidor = smtplib.SMTP(SMTP_SERVIDOR, SMTP_PORTA)

    servidor.starttls()
    servidor.login(EMAIL_REMETENTE, EMAIL_SENHA)

    servidor.sendmail(
        EMAIL_REMETENTE,
        email_destino,
        mensagem.as_string(),
    )

    servidor.quit()