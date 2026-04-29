from app import app, preparar_banco

if not preparar_banco():
    raise RuntimeError("Nao foi possivel inicializar o banco MySQL")
