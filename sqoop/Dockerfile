FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SQOOP_VERSION=1.4.7
ENV HADOOP_VERSION=2.7.7
ENV HADOOP_HOME=/usr/local/hadoop
ENV SQOOP_HOME=/usr/local/sqoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$SQOOP_HOME/bin

# Instalar Java, wget, curl, ssh y netcat
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk wget curl ssh rsync netcat && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Hadoop (cliente)
WORKDIR /usr/local
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Sqoop
# IMPORTANTE: Usamos el binario de sqoop-1.4.7.bin__hadoop-2.6.0, 
# aunque el cliente de Hadoop tenemos v2.7.7. No existe un binaro oficial de sqoop-hadoop con esta version. No hay problemas de compatibilidad.
WORKDIR /tmp
RUN wget -q https://archive.apache.org/dist/sqoop/${SQOOP_VERSION}/sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz && \
    tar -xzf sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz && \
    mv sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0 /usr/local/sqoop && \
    rm sqoop-${SQOOP_VERSION}.bin__hadoop-2.6.0.tar.gz

# MySQL connector
RUN wget -q https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar && \
    mv mysql-connector-java-5.1.49.jar $SQOOP_HOME/lib/

# JAVA_HOME SOLO para Sqoop
RUN JAVA_HOME_REAL=$(readlink -f /usr/bin/java | sed 's:/bin/java::') && \
    mkdir -p $SQOOP_HOME/conf && \
    echo "export JAVA_HOME=$JAVA_HOME_REAL" > $SQOOP_HOME/conf/sqoop-env.sh

# Permanencia de variables en sesiones interactivas
# El archivo .bashrc se carga cuando se inicia un shell interactivo (como docker exec -it)
RUN echo "" >> /root/.bashrc && \
    echo "# Cargar variables de entorno de Sqoop al iniciar el shell" >> /root/.bashrc && \
    echo "source \$SQOOP_HOME/conf/sqoop-env.sh" >> /root/.bashrc
# IMPORTANTE: El carácter '$' debe ser escapado como '\$' para que el valor 
# no se evalúe durante la construcción, sino durante la ejecución del shell.

# Mantener contenedor vivo. Sqoop NO debe arrancar como servicio. Es un CLI - batch
CMD ["tail", "-f", "/dev/null"]