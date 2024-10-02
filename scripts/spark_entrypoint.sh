#!/bin/bash
set -e

spark_master() {
  $SPARK_HOME/sbin/start-master.sh
  $SPARK_HOME/sbin/start-history-server.sh
  $SPARK_HOME/sbin/start-thriftserver.sh
}

spark_worker() {
  export SPARK_MASTER_URL=spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT
  export SPARK_WORKER_MEMORY=1G
  $SPARK_HOME/sbin/start-worker.sh spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT
  $SPARK_HOME/sbin/start-thriftserver.sh
}

if [[ $HOSTNAME == "spark-master" ]]; then
  echo "Starting Spark Master node..."
  export SPARK_MODE=master
  spark_master

elif [[ $HOSTNAME == "spark-worker" ]]; then
  echo "Starting Spark Worker node..."
  export SPARK_MODE=worker
  spark_worker

else
  echo "Unknown hostname. Exiting."
  exit 1
fi

tail -f /dev/null