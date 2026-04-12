## Responsável por enviar o código de verificação 2FA por email usando o protocolo SMTP
## No futuro poderemos expandir e criar o metódo do sms para aumentar as opções de 2FA 


import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

## Variaveis do env carregadas.
EMAIL_REMETENTE = os.getenv("EMAIL_REMETENTE")
EMAIL_SENHA = os.getenv("EMAIL_SENHA")
SMTP_SERVIDOR = "smtp.gmail.com"
SMTP_PORTA = 587


def enviar_codigo(email_destino, codigo):

    ## Gera o email utilizando a biblioteca email.mime
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