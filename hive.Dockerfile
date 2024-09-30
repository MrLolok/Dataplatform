FROM debian:bookworm-slim

# Installazione pacchetti
RUN apt-get update && apt-get install -y sudo wget openjdk-17-jdk

ARG HADOOP_VERSION=3.4.0
ARG HIVE_VERSION=4.0.0
ARG POSTGRESQL_JDBC_VERSION=42.7.4

# Installazione Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
RUN mkdir -p /home/hadoop
RUN tar -xvf hadoop-${HADOOP_VERSION}.tar.gz -C /home/hadoop --strip-components=1
RUN rm hadoop-*.tar.gz

# Installazione Hive
RUN wget https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz
RUN mkdir -p /home/hive
RUN tar -xvf apache-hive-${HIVE_VERSION}-bin.tar.gz -C /home/hive/ --strip-components=1
RUN rm apache-hive-*-bin.tar.gz

# Impostazione delle variabili di ambiente di Hive e Hadoop
ENV HIVE_HOME /home/hive
ENV PATH $HIVE_HOME/bin:$PATH
ENV HIVE_CONF_DIR /home/hive/conf

ENV HADOOP_HOME /home/hadoop
ENV HADOOP_OPTS="$HADOOP_OPTS --add-opens java.base/java.lang=ALL-UNNAMED"

# PostgreSQL JDBC Driver
RUN wget https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_VERSION}.jar -P $HIVE_HOME/lib/

# Creazione dei file di configurazione di Hive e Hadoop
COPY configs/hive-site.xml /home/hive/conf/hive-site.xml
COPY configs/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Crazione dell'utente 'hdfs' e impostazione dei permessi
RUN useradd -m hdfs
RUN chown -R hdfs:hdfs /home/hadoop
RUN chown -R hdfs:hdfs /home/hive

ENV HADOOP_USER_NAME hdfs
ENV HDFS_NAMENODE_USER=hdfs
ENV HDFS_DATANODE_USER=hdfs
ENV HDFS_SECONDARYNAMENODE_USER=hdfs

# Esposizione delle porte
EXPOSE 10000 10002

# Entrypoint script per Hive
COPY scripts/hive_entrypoint.sh /hive_entrypoint.sh
RUN chmod +x /hive_entrypoint.sh
ENTRYPOINT ["/hive_entrypoint.sh"]