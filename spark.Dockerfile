FROM spark:4.0.0-preview1-scala2.13-java17-python3-r-ubuntu

USER root
RUN mkdir -p /tmp/spark-events $SPARK_HOME/conf && \
    chown -R spark:spark /tmp/spark-events && \
    chown -R spark:spark $SPARK_HOME/conf

COPY --chown=spark spark/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf

# Entrypoint script per Spark
COPY scripts/spark_entrypoint.sh /spark_entrypoint.sh
RUN chmod +x /spark_entrypoint.sh

USER spark
ENTRYPOINT ["/spark_entrypoint.sh"]