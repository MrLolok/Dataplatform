FROM spark:3.5.2-scala2.12-java17-python3-r-ubuntu

ARG LIVY_VERSION=0.8.0
ARG LIVY_SCALA_VERSION=2.12
ENV LIVY_HOME /opt/livy

USER root
RUN mkdir -p $LIVY_HOME/logs
#RUN wget https://dlcdn.apache.org/incubator/livy/${LIVY_VERSION}-incubating/apache-livy-${LIVY_VERSION}-incubating_${LIVY_SCALA_VERSION}-bin.zip
COPY downloads/apache-livy-${LIVY_VERSION}-incubating_${LIVY_SCALA_VERSION}-bin.zip .
RUN unzip -d $LIVY_HOME apache-livy-*.zip && \
    mv $LIVY_HOME/*/* $LIVY_HOME && \
    rm -r $LIVY_HOME/apache-livy-${LIVY_VERSION}-incubating_${LIVY_SCALA_VERSION}-bin && \
    rm apache-livy-*.zip
RUN chown -R spark:spark $LIVY_HOME

# Entrypoint script per Livy
WORKDIR /opt/livy
COPY scripts/livy_entrypoint.sh /livy_entrypoint.sh
RUN chmod +x /livy_entrypoint.sh

USER spark
ENTRYPOINT ["/livy_entrypoint.sh"]