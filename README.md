Camus App

Aplicativo Flutter com backend em Flask para autenticação de usuários com 2FA via e-mail e recuperação de senha.

Pré-requisitos

Flutter >= 3.x

Python 3.10+

MySQL/MariaDB

adb para conectar o celular via USB

Editor de código (VS Code, IntelliJ, etc.)


Rodando o backend

Clone o repositório:

git clone <repo-url>
cd camus_app/server

Crie e ative o ambiente virtual:

python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

Instale as dependências:

pip install -r requirements.txt

Configure o arquivo .env com suas credenciais:

JWT_SECRET=<seu_jwt_secret>
EMAIL_REMETENTE=<seu_email>
EMAIL_SENHA=<senha_email>
JWT_ALGORITHM=HS256
JWT_EXPIRE_DAYS=7

Inicialize o banco de dados:

from database.db import criar_conexao, inicializar_banco
conexao = criar_conexao()
inicializar_banco(conexao)
conexao.close()

Rode o servidor:

python app.py

O servidor ficará disponível em http://127.0.0.1:5000.

Rodando o app Flutter

Conecte seu celular via USB e habilite a depuração. Verifique a conexão:

adb devices

Mapeie a porta para comunicar com o backend local:

adb reverse tcp:5000 tcp:5000

Entre na pasta do app Flutter e rode:

cd camus_app
flutter pub get
flutter run

O app se conectará ao backend rodando localmente no computador e você poderá testar cadastro, login com 2FA e recuperação de senha.

Estrutura resumida

server/: backend Flask, endpoints de autenticação, 2FA e recuperação de senha.

camus_app/: frontend Flutter com telas de login, cadastro, recuperação e redefinição de senha.

database/: scripts para criação de tabelas users, auth_codes e sessions.

service/ e repository/: organização do código de envio de e-mail, hashing, token JWT e persistência.


Notas

O sistema usa JWT para sessões com expiração curta (15 min para access token) e refresh token de 7 dias.

2FA e recuperação de senha usam códigos temporários enviados por e-mail.

Rate limiting aplicado para proteger endpoints sensíveis contra força bruta.