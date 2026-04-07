
openssl req -x509 -newkey rsa:4096 -nodes -keyout key.pem -out cert.pem -days 365 \
  -subj "/C=BR/ST=SP/L=Mogi/O=Camus/OU=Camus Main Group/CN=localhost"