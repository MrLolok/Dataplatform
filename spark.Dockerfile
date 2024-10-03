FROM spark:4.0.0-preview1-scala2.13-java17-python3-r-ubuntu

USER root
RUN mkdir -p /tmp/spark-events && chown -R spark:spark /tmp/spark-events

# Entrypoint script per Spark
COPY scripts/spark_entrypoint.sh /spark_entrypoint.sh
RUN chmod +x /spark_entrypoint.sh

USER spark
ENTRYPOINT ["/spark_entrypoint.sh"]