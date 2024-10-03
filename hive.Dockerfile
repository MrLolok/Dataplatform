FROM debian:bullseye-slim

# Installazione pacchetti
RUN apt-get update && apt-get install -y sudo wget ssh net-tools openjdk-11-jdk
RUN mkdir /var/run/sshd
RUN service ssh start

ARG HADOOP_VERSION=3.4.0
ARG HIVE_VERSION=4.0.0
ARG POSTGRESQL_JDBC_VERSION=42.7.4

# Impostazione delle variabili di ambiente di Hive e Hadoop
ENV HIVE_HOME /home/hive
ENV HIVE_CONF_DIR /home/hive/conf
ENV PATH $HIVE_HOME/bin:$PATH

ENV HADOOP_HOME /home/hadoop
ENV HADOOP_USER_NAME hdfs
ENV HDFS_NAMENODE_USER=$HADOOP_USER_NAME
ENV HDFS_DATANODE_USER=$HADOOP_USER_NAME
ENV HDFS_SECONDARYNAMENODE_USER=$HADOOP_USER_NAME
ENV HADOOP_OPTS="$HADOOP_OPTS --add-opens java.base/java.lang=ALL-UNNAMED"
ENV PATH $HADOOP_HOME/bin:$PATH

RUN useradd -m $HADOOP_USER_NAME
RUN mkdir -p $HADOOP_HOME $HIVE_HOME
RUN chown -R hdfs:hdfs $HADOOP_HOME
RUN chown -R hdfs:hdfs $HIVE_HOME

# Installazione Hadoop
#RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
COPY downloads/hadoop-${HADOOP_VERSION}.tar.gz .
RUN tar --owner=$HADOOP_USER_NAME -xvf hadoop-${HADOOP_VERSION}.tar.gz -C $HADOOP_HOME --strip-components=1 && \
    rm $HADOOP_HOME/share/hadoop/common/lib/slf4j-reload4j-*.jar && \
    rm hadoop-*.tar.gz

# Installazione Hive
#RUN wget https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz
COPY downloads/apache-hive-${HIVE_VERSION}-bin.tar.gz .
RUN tar --owner=$HADOOP_USER_NAME -xvf apache-hive-${HIVE_VERSION}-bin.tar.gz -C $HIVE_HOME --strip-components=1 && \
    rm apache-hive-*-bin.tar.gz

# PostgreSQL JDBC Driver
RUN wget https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_VERSION}.jar -P $HIVE_HOME/lib/

# Creazione dei file di configurazione di Hive e Hadoop
COPY --chown=$HADOOP_USER_NAME hive/hive-site.xml /home/hive/conf/hive-site.xml
COPY --chown=$HADOOP_USER_NAME hadoop/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Esposizione delle porte
EXPOSE 9083 10000 10002

# Entrypoint script per Hive
COPY scripts/hive_entrypoint.sh /hive_entrypoint.sh
RUN chmod +x /hive_entrypoint.sh
ENTRYPOINT ["/hive_entrypoint.sh"]