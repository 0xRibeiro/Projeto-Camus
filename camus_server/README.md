Camus Server 

Backend simples em Flask para cadastro de usuario com persistencia em MySQL.

O que ja faz

- Sobe uma API HTTP com Flask.
- Inicializa a tabela `users` automaticamente ao iniciar.
- Expoe a rota `POST /cadastrar` para criar usuario.
- Valida campos obrigatorios: `nome`, `email`, `senha`.
- Salva o usuario no banco e retorna `id`, `nome`, `email`.

Estrutura resumida

- `app.py`: rota de cadastro e fluxo principal.
- `database/db.py`: conexao MySQL e criacao da tabela.
- `model/user.py`: modelo `Usuario`.
- `repository/user_repository.py`: insercao no banco.

Banco de dados

Configuracao atual fixa no codigo (`database/db.py`):

- IP: `127.0.0.1`
- Porta: `3306`
- Usuario: `root`
- Senha: vazia
- Banco: `camus`

Tabela usada:

- `users(id, nome, email, senha)`

Como executar

1. Garanta que o MySQL esteja ativo e que o banco `camus` exista.
2. Instale dependencias:

pip install flask mysql-connector-python

3. Rode a API:

python app.py

## Teste rapido da rota

curl -X POST http://127.0.0.1:5000/cadastrar \
	-H "Content-Type: application/json" \
	-d '{"nome":"Victor","email":"victor@email.com","senha":"123456"}'

Respostas esperadas:

- `201`: usuario cadastrado.
- `400`: faltam campos obrigatorios.
- `500`: erro interno (ex.: falha no banco).

## Observacao

Neste momento a senha esta sendo salva em texto puro. O proxímo passo será
terminar o CRUD e iniciar a criptografia.