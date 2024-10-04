# Avvio

### Creazione delle immagini
La creazione delle immagini *custom* di Docker (`hadoop.Dockerfile`, `hive.Dockerfile`, `livy.Dockerfile` e `spark.Dockerfile`) avviene attraverso il seguente comando:

```shell

docker  compose  build

```

### Avvio dei container
Avviare i container (pull immagini + esecuzione) consente di far partire i seguenti servizi dell'ecosistema Hadoop

 - Hadoop: NameNode
 - Hadoop: DataNode
 - Hadoop: YARN ResourceManager
 - Hadoop: YARN NodeManager
 - Database relazionale: Postgres
 - Database Web UI: PGAdmin
 - Hive: Hive Metastore + HiveServer2
 - Impala: Impalad (Coordinator & Executor)
 - Impala: StateStore
 - Impala: Catalog
 - Spark: Spark Master
 - Spark: Spark Worker
 - Livy
 - Hue

```shell

docker  compose  up  -d

```
### Interruzione dei container

Per interrompere i container è possibile eseguire il comando

```shell

docker  compose  stop

```
In alternativa, per eliminarli insieme ai volumi, basta eseguire

```shell

docker  compose  down -v

```