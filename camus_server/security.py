import bcrypt

# fator de custo do bcrypt (recomendado)
COST_FACTOR = 12  

"""
Justificativa: O fator de custo 12 foi utilizado na configuração do algoritmo bcrypt, estabelecendo a complexidade computacional do processo de criação do hash. Esse valor foi selecionado por proporcionar um equilíbrio apropriado entre segurança e desempenho, sendo fortemente recomendado por entidades como a OWASP. O crescimento dos custos torna os ataques de força bruta consideravelmente mais desafiadores, uma vez que aumenta o tempo necessário para calcular cada tentativa de senha.

"""
def gerar_hash_senha(senha: str) -> str:
    """
    Uso de salt criptográfico único por usuário.

    O bcrypt cria um salt aleatório para cada senha de forma automática.
    por meio da função gensalt(). Esse salt é integrado diretamente
    no hash final que está guardado no banco de dados.

    Isso previne ataques como rainbow tables e assegura que duas senhas
    iguais gerem hashes distintos.
    """
    salt = bcrypt.gensalt(rounds=COST_FACTOR)
    senha_hash = bcrypt.hashpw(senha.encode("utf-8"), salt)
    return senha_hash.decode("utf-8")