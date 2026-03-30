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

```bash
git clone https://github.com/0xRibeiro/Projeto-Camus
cd Projeto-Camus/camus_server
```
Crie e ative o ambiente virtual:

```bash
python -m venv venv
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows
```


Crie e configure o arquivo .env com suas credenciais seguindo o .env.example


Rode o servidor:
```python
python app.py
```
O servidor ficará disponível em http://127.0.0.1:5000.

Rodando o app Flutter

Conecte seu celular via USB e habilite a depuração. Verifique a conexão:
```bash
adb devices
```
Mapeie a porta para comunicar com o backend local:
```bash
adb reverse tcp:5000 tcp:5000
```
Entre na pasta do app Flutter e rode:
```bash
cd camus_app
flutter run
```
O app se conectará ao backend rodando localmente no computador e você poderá testar cadastro, login com 2FA e recuperação de senha.

Estrutura resumida

camus_server/: backend Flask, endpoints de autenticação, 2FA e recuperação de senha.

camus_app/: frontend Flutter com telas de login, cadastro, recuperação e redefinição de senha.

camus_firmware/: firmware do ESP32 que vai rodar o projeto IoT


Notas

O sistema usa JWT para sessões com expiração curta e refresh token de 7 dias.

2FA e recuperação de senha usam códigos temporários enviados por e-mail.

Rate limiting aplicado para proteger endpoints sensíveis contra força bruta.
