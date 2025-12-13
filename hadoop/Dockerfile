FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HADOOP_VERSION=2.7.7
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN apt-get update && apt-get install -y \
    openjdk-8-jdk openssh-server pdsh wget nano curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} $HADOOP_HOME \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# 🔥 JAVA_HOME correcto (clave)
RUN JAVA_HOME_REAL=$(readlink -f /usr/bin/java | sed 's:/bin/java::') && \
    echo "export JAVA_HOME=$JAVA_HOME_REAL" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

COPY ./conf/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./conf/mapred-site.xml $HADOOP_HOME/etc/hadoop/

RUN mkdir -p $HADOOP_HOME/hadoop_storage/hdfs/namenode \
             $HADOOP_HOME/hadoop_storage/hdfs/datanode

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys

CMD service ssh restart && \
    hdfs namenode -format -force && \
    start-dfs.sh && \
    start-yarn.sh && \
    tail -f /dev/null
