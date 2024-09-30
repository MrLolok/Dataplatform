#!/bin/bash
set -e
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

if [[ $HOSTNAME == "namenode" ]]; then
  if [ ! -d "/home/hadoop/dfs/name/current" ]; then
    echo "Formatting NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
  fi

  echo "Starting NameNode..."
  hdfs namenode

elif [[ $HOSTNAME == "datanode" ]]; then
  echo "Starting DataNode..."
  hdfs datanode
  tail -f /dev/null

elif [[ $HOSTNAME == "resourcemanager" ]]; then
  echo "Starting ResourceManager..."
  yarn resourcemanager

elif [[ $HOSTNAME == "nodemanager" ]]; then
  echo "Starting NodeManager..."
  yarn nodemanager
  tail -f /dev/null

else
  echo "Unknown hostname. Exiting."
  exit 1
fi