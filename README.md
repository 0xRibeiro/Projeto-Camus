# Projeto-Camus
Sistema de monitoramento de aquários

# Camus App

Aplicativo Flutter com backend em Flask para autenticação de usuários com 2FA via e-mail e recuperação de senha.

## Pré-requisitos
Flutter >= 3.x, Python 3.10+, MySQL/MariaDB, adb para conectar o celular via USB, editor de código.

## Rodando o projeto
Clone o repositório: `git clone <repo-url>` e entre na pasta `cd camus_app/server`. Crie e ative um ambiente virtual: `python -m venv venv` e `source venv/bin/activate` (Linux/macOS) ou `venv\Scripts\activate` (Windows). Instale as dependências com `pip install -r requirements.txt`. Configure o arquivo `.env` com suas credenciais (`JWT_SECRET`, `EMAIL_REMETENTE`, `EMAIL_SENHA`, `JWT_ALGORITHM`, `JWT_EXPIRE_DAYS`). Inicialize o banco de dados abrindo o Python (`python`) e executando `from database.db import criar_conexao, inicializar_banco; conexao = criar_conexao(); inicializar_banco(conexao); conexao.close()`, depois saia do Python (`exit()`). Rode o servidor Flask com `python app.py`. Ele ficará disponível em `http://127.0.0.1:5000`.

No app Flutter, conecte seu celular via USB com depuração habilitada e verifique a conexão com `adb devices`. Faça o mapeamento da porta para comunicar com o backend local: `adb reverse tcp:5000 tcp:5000`. No app, configure a URL do backend para `http://127.0.0.1:5000` caso necessário. Instale dependências e rode o app: `flutter pub get` e `flutter run`. Agora o app deve se comunicar com o backend, permitindo cadastro, login com 2FA e recuperação de senha.

## Funcionalidades
- Cadastro de usuário com hash seguro (bcrypt)  
- Login com autenticação de dois fatores via e-mail  
- Recuperação de senha usando token temporário enviado por e-mail  
- Logout e invalidação de sessões  
- Rate limit em endpoints sensíveis para proteção contra força bruta  
- Sessões com expiração configurada  

## Estrutura resumida
- `app.py` — endpoints e lógica de autenticação  
- `database/` — scripts de conexão e inicialização do MySQL  
- `repository/` — acesso ao banco para usuários, sessões e códigos  
- `service/` — envio de e-mail e geração de tokens  
- `model/` — definições de entidades como usuário, sessão e códigos  
- `ui/` — telas Flutter e viewmodels para interação com o usuário

