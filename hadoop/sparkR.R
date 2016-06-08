Sys.setenv(HADOOP_CONF="/data/hadoop/etc/hadoop")
Sys.setenv(YARN_CONF="/data/hadoop/etc/hadoop")
Sys.setenv(SPARK_HOME="/data/hadoop/spark")

.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R/lib"), .libPaths()))
library(SparkR)

sc = sparkR.init(master="yarn-client")
sqlContext = sparkRSQL.init(sc)


## json

j = jsonFile(sqlContext, "hdfs://localhost:9000/data/short_1e6.json")

res = count(group_by(j, "author"))
res2 = collect(res)

registerTempTable(j, "reddit")
res = sql(sqlContext, "SELECT author, COUNT(*) as n FROM reddit GROUP BY author")
res2 = collect(res)



## df

df = read.df(sqlContext, "hdfs://localhost:9000/data/short_1e6.json", source = "json")

res = count(group_by(df, "author"))
res2 = collect(res)

registerTempTable(df, "reddit")
res = sql(sqlContext, "SELECT author, COUNT(*) as n FROM reddit GROUP BY author")
res2 = collect(res)

sparkR.stop() # Stop sparkR



## CSV

Sys.setenv('SPARKR_SUBMIT_ARGS'='"--packages" "com.databricks:spark-csv_2.10:1.0.3" "sparkr-shell"')

sc = sparkR.init(master="yarn-client")
sqlContext = sparkRSQL.init(sc)

house = read.df(sqlContext,"hdfs://localhost:9000/data/housing.txt", "com.databricks.spark.csv", header="false")

sparkR.stop() # Stop sparkR