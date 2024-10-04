FROM debian:bookworm-slim

# Installazione pacchetti Debian
RUN apt-get update && apt-get install -y sudo wget nano unzip net-tools python3 python3-pip openjdk-17-jdk
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64

ARG SPARK_VERSION=3.5.3
ARG LIVY_VERSION=0.8.0
ARG LIVY_SCALA_VERSION=2.12

ENV SPARK_HOME=/usr/lib/spark
ENV SPARK_CONF_DIR=$SPARK_HOME/conf
ENV HADOOP_CONF_DIR=/etc/hadoop/conf

# Imposta variabili d'ambiente per Livy
ENV LIVY_HOME=/opt/livy
ENV LIVY_CONF_DIR=/opt/livy/conf
ENV PATH=$LIVY_HOME/bin:$PATH

#RUN wget https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz
COPY downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz .
RUN mkdir -p $SPARK_HOME && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz -C $SPARK_HOME --strip-components=1 && \
    rm spark-*.tgz

#RUN wget https://dlcdn.apache.org/incubator/livy/${LIVY_VERSION}-incubating/apache-livy-${LIVY_VERSION}-incubating_${LIVY_SCALA_VERSION}-bin.zip
COPY downloads/apache-livy-${LIVY_VERSION}-incubating_${LIVY_SCALA_VERSION}-bin.zip .
RUN mkdir -p $LIVY_HOME/logs && \
    unzip -d $LIVY_HOME apache-livy-*.zip && \
    mv $LIVY_HOME/*/* $LIVY_HOME && \
    rm -r $LIVY_HOME/apache-livy-* && rm apache-livy-*.zip

# Impostazione dei permessi
RUN chmod +x $LIVY_HOME/bin/livy-server


ENV HADOOP_USER_NAME=hdfs
RUN useradd -m $HADOOP_USER_NAME && \
    chown -R $HADOOP_USER_NAME:$HADOOP_USER_NAME /usr/lib/spark && \
    chown -R $HADOOP_USER_NAME:$HADOOP_USER_NAME /opt/livy
USER $HADOOP_USER_NAME

# Entrypoint script per Livy
EXPOSE 8998
CMD ["livy-server"]