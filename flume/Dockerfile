FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    FLUME_VERSION=1.11.0 \
    HADOOP_VERSION=2.7.7 \
    FLUME_HOME=/opt/flume \
    HADOOP_HOME=/usr/local/hadoop

# Java 8 y utilidades básicas
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk wget curl netcat-openbsd vim nano \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Apache Flume
WORKDIR /tmp
RUN wget -q https://dlcdn.apache.org/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz \
 && tar -xzf apache-flume-${FLUME_VERSION}-bin.tar.gz \
 && mv apache-flume-${FLUME_VERSION}-bin ${FLUME_HOME} \
 && rm apache-flume-${FLUME_VERSION}-bin.tar.gz

# Instalar Hadoop SOLO como cliente (mismas version que el NameNode)
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
 && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
 && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
 && rm hadoop-${HADOOP_VERSION}.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

ENV PATH=${JAVA_HOME}/bin:${FLUME_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}

# Configurar flume-env.sh para que incluya Hadoop en el classpath
RUN echo "export JAVA_HOME=${JAVA_HOME}" > ${FLUME_HOME}/conf/flume-env.sh \
 && echo "export HADOOP_HOME=${HADOOP_HOME}" >> ${FLUME_HOME}/conf/flume-env.sh \
 && echo "export HADOOP_CONF_DIR=${HADOOP_CONF_DIR}" >> ${FLUME_HOME}/conf/flume-env.sh \
 && echo 'FLUME_CLASSPATH="$FLUME_CLASSPATH:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/hdfs/lib/*"' >> ${FLUME_HOME}/conf/flume-env.sh

WORKDIR ${FLUME_HOME}

# CMD por defecto (se sobreescribe en docker-compose con -f agent-config)
CMD ["flume-ng", "agent", "--conf", "/opt/flume/conf", "--conf-file", "/opt/flume/conf/flume.conf", "--name", "agent1", "-Dflume.root.logger=INFO,console"]
