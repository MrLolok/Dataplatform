FROM debian:bullseye-slim

# Installazione pacchetti Debian
RUN apt-get update && apt-get install -y sudo wget ssh net-tools openjdk-11-jdk
RUN mkdir /var/run/sshd
RUN service ssh start

ARG HADOOP_VERSION=3.4.0

# Crazione dell'utente 'hdfs' e impostazione delle variabili d'ambiente
ENV HADOOP_HOME /home/hadoop
ENV HADOOP_USER_NAME hdfs
ENV HDFS_NAMENODE_USER=$HADOOP_USER_NAME
ENV HDFS_DATANODE_USER=$HADOOP_USER_NAME
ENV HDFS_SECONDARYNAMENODE_USER=$HADOOP_USER_NAME
ENV HADOOP_OPTS="$HADOOP_OPTS --add-opens java.base/java.lang=ALL-UNNAMED"
ENV PATH $HADOOP_HOME/bin:$PATH

RUN useradd -m $HADOOP_USER_NAME
RUN mkdir -p $HADOOP_HOME/tmp $HADOOP_HOME/logs $HADOOP_HOME/data
RUN chown -R hdfs:hdfs $HADOOP_HOME

# Installazione Hadoop
#RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
COPY downloads/hadoop-${HADOOP_VERSION}.tar.gz .
RUN tar --owner=$HADOOP_USER_NAME -xvf hadoop-${HADOOP_VERSION}.tar.gz -C $HADOOP_HOME --strip-components=1
RUN rm hadoop-*.tar.gz

# Impostazione SSH passwordless per le comunicazioni di Hadoop
RUN ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Creazione dei file di configurazione di Hadoop
COPY --chown=$HADOOP_USER_NAME configs/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY --chown=$HADOOP_USER_NAME configs/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY --chown=$HADOOP_USER_NAME configs/mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY --chown=$HADOOP_USER_NAME configs/yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY --chown=$HADOOP_USER_NAME configs/hadoop-env.sh $HADOOP_HOME/etc/hadoop/

# Esposizione delle porte
EXPOSE 19888 9870 9864 9820 8090 8088 8042

# Entrypoint script per NameNode e DataNode
COPY scripts/hadoop_entrypoint.sh /hadoop_entrypoint.sh
RUN chmod +x /hadoop_entrypoint.sh
ENTRYPOINT ["/hadoop_entrypoint.sh"]