#!/bin/bash
set -e

$HADOOP_HOME/sbin/start-dfs.sh

if schematool -dbType postgres -info | grep -q "Schema version"; then
    echo "Hive schema already initialized."
else
    echo "Initializing Hive schema..."
    schematool -dbType postgres -initSchema --verbose || echo "Schema already initialized or encountered an error."
fi

hive --service metastore &
hive --service hiveserver2