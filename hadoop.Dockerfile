FROM debian:bookworm-slim

# Installazione pacchetti Debian
RUN apt-get update && apt-get install -y sudo wget ssh openjdk-17-jdk
RUN mkdir /var/run/sshd
RUN service ssh start

ARG HADOOP_VERSION=3.4.0

# Installazione Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
RUN mkdir -p /home/hadoop
RUN tar -xvf hadoop-${HADOOP_VERSION}.tar.gz -C /home/hadoop --strip-components=1
RUN rm hadoop-*.tar.gz

# Impostazione delle variabili di ambiente di Hadoop
ENV HADOOP_HOME /home/hadoop
ENV HADOOP_OPTS="$HADOOP_OPTS --add-opens java.base/java.lang=ALL-UNNAMED"
ENV PATH $HADOOP_HOME/bin:$PATH
RUN mkdir -p /home/hadoop/tmp /home/hadoop/logs /home/hadoop/data

# Impostazione SSH passwordless per le comunicazioni di Hadoop
RUN ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Creazione dei file di configurazione di Hadoop
COPY configs/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY configs/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY configs/mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY configs/yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY configs/hadoop-env.sh $HADOOP_HOME/etc/hadoop/

# Crazione dell'utente 'hdfs' e impostazione dei permessi
RUN useradd -m hdfs
RUN chown -R hdfs:hdfs /home/hadoop

ENV HADOOP_USER_NAME hdfs
ENV HDFS_NAMENODE_USER=hdfs
ENV HDFS_DATANODE_USER=hdfs
ENV HDFS_SECONDARYNAMENODE_USER=hdfs

# Esposizione delle porte
EXPOSE 9870 9864 9820 8090 8088 8042

# Entrypoint script per NameNode e DataNode
COPY scripts/hadoop_entrypoint.sh /hadoop_entrypoint.sh
RUN chmod +x /hadoop_entrypoint.sh
ENTRYPOINT ["/hadoop_entrypoint.sh"]