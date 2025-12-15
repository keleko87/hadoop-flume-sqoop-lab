#!/bin/bash
# start-hadoop.sh

# 1. INICIAR SSH
echo "Iniciando servicio SSH..."
/etc/init.d/ssh start

# 2. ESPERA ACTIVA DE SSH (Necesaria para evitar 'Connection refused')
echo "Esperando a que el puerto 22 esté abierto..."
i=0
while ! nc -z localhost 22; do
    i=$((i+1))
    if [ $i -ge 10 ]; then
        echo "Error: SSH no está disponible después de $i intentos."
        exit 1
    fi
    sleep 1
done
echo "SSH listo."

# 3. CONFIGURACIÓN DE HOSTS Y SSH (Permanencia asegurada en cada arranque)
# a) Inyección del host (necesario para la conexión SSH interna)
if ! grep -q "127.0.0.1 hadoop" /etc/hosts; then
    echo "127.0.0.1 hadoop" >> /etc/hosts
fi

# b) Configuración de SSH para evitar prompts de autenticidad
echo "Configurando SSH para conexión sin claves..."
mkdir -p ~/.ssh

# Escribir el archivo ~/.ssh/config
cat <<EOF > ~/.ssh/config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile /dev/null
EOF
chmod 600 ~/.ssh/config

# c) Forzar la prueba de conexión (purga) para evitar errores de pdsh
ssh localhost exit
ssh hadoop exit
echo "Configuración SSH completada."


# 4. FORMATEAR NAMENODE (Solo la primera vez)
if [ ! -d $HADOOP_HOME/hadoop_storage/hdfs/namenode/current ]; then
  echo "Formateando NameNode..."
  $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
fi

# 5. INICIAR HDFS Y YARN
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# 6. MANTENER EL CONTENEDOR VIVO
tail -f /dev/null