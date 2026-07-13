#!/usr/bin/env bash
# Provisiona MongoDB 8.0 sobre Ubuntu 22.04 (jammy) en el primer arranque.
# El log queda en /var/log/user-data.log (entrar vía la instancia de app como bastión).
exec > /var/log/user-data.log 2>&1
set -x

apt-get update
apt-get install -y gnupg curl

# Repositorio oficial de MongoDB 8.0 (Ubuntu no lo trae en sus fuentes)
curl -fsSL https://pgp.mongodb.com/server-8.0.asc \
  | gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" \
  > /etc/apt/sources.list.d/mongodb-org-8.0.list

apt-get update
apt-get install -y mongodb-org

# Por defecto mongod solo escucha en localhost y la app no podría conectarse.
# Abrir a 0.0.0.0 es seguro aquí: el security group solo deja pasar a la app.
sed -i 's/^\( *bindIp:\).*/\1 0.0.0.0/' /etc/mongod.conf

systemctl enable --now mongod
