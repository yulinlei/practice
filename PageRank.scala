import org.apache.spark.SparkConf
import org.apache.spark.SparkContext

/* Do not include any other Spark libraries.
 * e.g. import org.apache.spark.sql._ */

/* Part5
 * This program prints out the 10 pages with the highest pagerank. */

object Part5 {
    def main(args: Array[String]) {
        if (args.length <= 1 || 4 <= args.length) {
            System.err.println("Usage: Part5 <links-simple-sorted> <titles-sorted> <iterations>")
            System.exit(1)
        }

        val iters = if (args.length == 3) args(2).toInt else 10

        val conf = new SparkConf()
            .setMaster("local[*]")
            .setAppName("Part5")
            //.set("spark.executor.memory", "4g")

        val sc = new SparkContext(conf)

        val links = sc.textFile(args(0), 32).map{ s => val parts = s.split(": ")
             (parts(0).toInt, parts(1).split(" ").map(s=>(s.toInt)))}.cache()

        val titles = sc.textFile(args(1), 32).zipWithIndex
             .map{case (k,v) => ((v+1).toInt,k)}

        /* PageRank */
        val N = titles.count()
        var ranks = links.mapValues(s => 100.0/N)
        for (i <- 1 to iters) {
            val iterpart = links.join(ranks).values.flatMap{case (outlinks,rank) => 
            val num = outlinks.size
                outlinks.map(outlink => (outlink, rank / num))
            }/* Iteration part of the formula. */

            /* Take those nodes having no outlinks into account. */
            val temp = titles.subtractByKey(iterpart).map{case (k,v) => (k.toInt,0.0)}
            ranks = iterpart.union(temp).reduceByKey((a,b) => (a+b))
            .mapValues(v => 0.15*100/N+0.85*v)
        }
        val top = ranks.takeOrdered(10)(Ordering[Double].reverse.on(s => s._2))
        val result = sc.parallelize(top)
        println("\n[ PAGERANKS ]")
        result.join(titles).mapValues{case(k,v) => (v,k)}
        .takeOrdered(10)(Ordering[Double].reverse.on(s => s._2._2)).foreach(println)
    }
}
