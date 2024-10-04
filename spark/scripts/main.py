from pyspark.sql import SparkSession

def main():
    spark = SparkSession.builder \
        .appName("Simple Sum Job") \
        .getOrCreate()
    data = [(1,), (2,), (3,), (4,), (5,)]
    df = spark.createDataFrame(data, ["number"])
    total_sum = df.groupBy().sum("number").collect()[0][0]
    print(f"Total sum of numbers: {total_sum}")
    spark.stop()

if __name__ == "__main__":
    main()