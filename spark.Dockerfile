FROM spark:3.5.2-scala2.12-java17-python3-r-ubuntu

ENV HADOOP_CONF_DIR /etc/hadoop/conf
ENV SPARK_CONF_DIR $SPARK_HOME/conf

USER root
RUN mkdir -p /tmp/spark-events $SPARK_HOME/conf && \
    chown -R spark:spark /tmp/spark-events && \
    chown -R spark:spark $SPARK_HOME/conf

# Entrypoint script per Spark
COPY scripts/spark_entrypoint.sh /spark_entrypoint.sh
RUN chmod +x /spark_entrypoint.sh

USER spark
ENTRYPOINT ["/spark_entrypoint.sh"]