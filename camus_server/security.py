import bcrypt

# 1.1 Uso de hash criptográfico seguro para senhas (bcrypt)
# 1.2 Parâmetros de custo do hash configurados e justificados
# fator de custo do bcrypt (recomendado)
COST_FACTOR = 12  

"""
Justificativa: O fator de custo 12 foi utilizado na configuração do algoritmo bcrypt, estabelecendo a complexidade computacional do processo de criação do hash. Esse valor foi selecionado por proporcionar um equilíbrio apropriado entre segurança e desempenho, sendo fortemente recomendado por entidades como a OWASP. O crescimento dos custos torna os ataques de força bruta consideravelmente mais desafiadores, uma vez que aumenta o tempo necessário para calcular cada tentativa de senha.

"""

def gerar_hash_senha(senha: str) -> str:
    """
    1.3 Uso de salt criptográfico único por usuário.

    O bcrypt cria um salt aleatório para cada senha de forma automática.
    por meio da função gensalt(). Esse salt é integrado diretamente
    no hash final que está guardado no banco de dados.

    Isso previne ataques como rainbow tables e assegura que duas senhas
    iguais gerem hashes distintos.

    1.4 Armazenamento correto do hash + salt.
    O valor retornado já contém o hash e o salt no mesmo campo.
    """
    salt = bcrypt.gensalt(rounds=COST_FACTOR)
    senha_hash = bcrypt.hashpw(senha.encode("utf-8"), salt)
    return senha_hash.decode("utf-8")


def verificar_senha(senha: str, senha_hash: str) -> bool:
    """
    A função bcrypt.checkpw() é utilizada para comparar a senha fornecida
    pelo usuário com o hash armazenado no banco de dados. O bcrypt extrai
    automaticamente o salt do hash armazenado e o utiliza para calcular o hash
    da senha fornecida, garantindo uma comparação segura e eficiente.
    """
    return bcrypt.checkpw(
        senha.encode("utf-8"),
        senha_hash.encode("utf-8")
    )