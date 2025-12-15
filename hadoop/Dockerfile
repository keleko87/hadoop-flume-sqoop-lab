FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HADOOP_VERSION=2.7.7
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HADOOP_HOME/sbin

# 1. INSTALACIÓN DE DEPENDENCIAS (Java 8, SSH, PDSH y netcat-openbsd)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk openssh-server pdsh wget nano curl netcat-openbsd iproute2 vim && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. DESCARGA Y EXTRACCIÓN DE HADOOP
WORKDIR /tmp
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} $HADOOP_HOME \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# 3. CONFIGURACIÓN PERMANENTE DE JAVA_HOME
# Encuentra la ruta real de Java 8 y la inyecta en hadoop-env.sh
RUN JAVA_HOME_REAL=$(readlink -f /usr/bin/java | sed 's:/bin/java::') && \
    echo "export JAVA_HOME=$JAVA_HOME_REAL" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# 4. CONFIGURACIÓN PERMANENTE DE SSH (CLAVES Y StrictHostKeyChecking no)
# Esto soluciona el problema de "authenticity" y "Connection refused" en pdsh.
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 700 ~/.ssh \
    && chmod 600 ~/.ssh/id_rsa \
    && chmod 600 ~/.ssh/authorized_keys \
    && mkdir -p ~/.ssh \
    && echo "Host *\n  StrictHostKeyChecking no\n  UserKnownHostsFile /dev/null\n" > ~/.ssh/config \
    && chmod 600 ~/.ssh/config \
    && rm -f ~/.ssh/known_hosts

# 5. COPIAR ARCHIVOS DE CONFIGURACIÓN
COPY ./conf/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/mapred-site.xml $HADOOP_HOME/etc/hadoop/

# 6. CREAR DIRECTORIOS DE HDFS
# RUN mkdir -p $HADOOP_HOME/hadoop_storage/hdfs/namenode \
#              $HADOOP_HOME/hadoop_storage/hdfs/datanode
RUN mkdir -p $HADOOP_HOME/hadoop_storage/hdfs/namenode \
             $HADOOP_HOME/hadoop_storage/hdfs/datanode \
             $HADOOP_HOME/hadoop_storage/tmp && \
    chmod -R 755 $HADOOP_HOME/hadoop_storage

# 7. COPIAR SCRIPT DE INICIO (Maneja la lógica de hosts, espera SSH y arranque de HDFS)
COPY ./start-hadoop.sh /usr/local/bin/start-hadoop.sh
RUN chmod +x /usr/local/bin/start-hadoop.sh

# 8. CMD final llama al script de inicio
CMD ["/usr/local/bin/start-hadoop.sh"]