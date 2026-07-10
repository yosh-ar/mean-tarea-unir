#!/usr/bin/env bash
# Provisiona MongoDB 8.0 sobre Ubuntu 22.04 (jammy) en el primer arranque.
exec > /var/log/user-data.log 2>&1
set -x

# Actualiza los índices de paquetes antes de instalar nada
apt-get update

# Instala las dependencias necesarias para importar la clave y el repositorio
apt-get install -y gnupg curl

# Importa la clave GPG oficial de MongoDB 8.0
curl -fsSL https://pgp.mongodb.com/server-8.0.asc \
  | gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg

# Registra el repositorio de MongoDB 8.0 para jammy, firmado con la clave anterior
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" \
  > /etc/apt/sources.list.d/mongodb-org-8.0.list

# Actualiza índices e instala MongoDB
apt-get update
apt-get install -y mongodb-org

# Habilita la escucha en todas las interfaces (la red ya restringe el acceso al SG de la app)
sed -i 's/^\( *bindIp:\).*/\1 0.0.0.0/' /etc/mongod.conf

# Arranca y habilita el servicio de MongoDB
systemctl enable --now mongod
