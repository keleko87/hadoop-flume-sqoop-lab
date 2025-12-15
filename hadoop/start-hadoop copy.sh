#!/bin/bash
# start-hadoop.sh

# Iniciar SSH
/etc/init.d/ssh start

# --- Espera Activa para SSH ---
echo "Esperando a que el servicio SSH esté listo..."
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

# Inyección del host (necesario para la conexión SSH interna)
if ! grep -q "127.0.0.1 hadoop" /etc/hosts; then
    echo "127.0.0.1 hadoop" >> /etc/hosts
fi

# --- PRUEBA DE CONEXIÓN SSH (CRÍTICO) ---
# Forzar la conexión a sí mismo para evitar el error "Connection refused" en pdsh
# La configuración StrictHostKeyChecking no del Dockerfile se encarga de esto.
echo "Purgando errores SSH..."
ssh localhost exit
ssh hadoop exit
echo "Pruebas SSH completadas."
# ----------------------------------------


# Formatear NameNode solo si la carpeta está vacía
if [ ! -d $HADOOP_HOME/hadoop_storage/hdfs/namenode/current ]; then
  echo "Formateando NameNode..."
  $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
fi

# Iniciar HDFS y YARN
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# Mantener el contenedor en ejecución
tail -f /dev/null