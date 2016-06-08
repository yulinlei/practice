### Initialization of Rhipe and Hadoop

Sys.setenv(HADOOP="/data/hadoop")
Sys.setenv(HADOOP_HOME="/data/hadoop")
Sys.setenv(HADOOP_BIN="/data/hadoop/bin") 
Sys.setenv(HADOOP_CMD="/data/hadoop/bin/hadoop") 
Sys.setenv(HADOOP_CONF_DIR="/data/hadoop/etc/hadoop") 
Sys.setenv(HADOOP_LIBS=system("/data/hadoop/bin/hadoop classpath | tr -d '*'",TRUE))


if (!("Rhipe" %in% installed.packages()))
{
  install.packages("/data/hadoop/rhipe/Rhipe_0.75.1.6_hadoop-2.tar.gz", repos=NULL)
}

library(Rhipe)
rhinit()


## Uncomment following lines if you need non-base packages
rhoptions(zips = '/R/R.Pkg.tar.gz')
rhoptions(runner = 'sh ./R.Pkg/library/Rhipe/bin/RhipeMapReduce.sh')


## User Comment Example

user_reduce = expression(
  pre = {
    total = 0
  },
  reduce = {
    total = total + sum(unlist(reduce.values))
  },
  post = {
    rhcollect(reduce.key, total)
  }
)

user_map = expression({
  suppressMessages(library(jsonlite))
  
  lapply(
    seq_along(map.keys), 
    function(r) 
    {
      key = fromJSON(map.values[[r]])$subreddit
      value = 1
      rhcollect(key,value)
    }
  )
})

## January
user_January = rhwatch(
  map      = user_map,
  reduce   = user_reduce,
  input    = rhfmt("/data/RC_2015-01.json", type = "text")
)
## February
user_February = rhwatch(
  map      = user_map,
  reduce   = user_reduce,
  input    = rhfmt("/data/RC_2015-02.json", type = "text")
)
## March
user_March = rhwatch(
  map      = user_map,
  reduce   = user_reduce,
  input    = rhfmt("/data/RC_2015-03.json", type = "text")
)
## April
user_April = rhwatch(
  map      = user_map,
  reduce   = user_reduce,
  input    = rhfmt("/data/RC_2015-04.json", type = "text")
)
## May
user_May = rhwatch(
  map      = user_map,
  reduce   = user_reduce,
  input    = rhfmt("/data/RC_2015-05.json", type = "text")
)

get_val = function(x,i) x[[i]]

counts1 = data.frame(key = sapply(user_January,get_val,i=1),
              value = sapply(user_January,get_val,i=2), stringsAsFactors=FALSE)
sort1 <- counts1[with(counts1,order(value,decreasing = TRUE)),]
sort1 <- data.frame(sort1,rank=1:nrow(sort1))
top25_1 <- head(sort1,25)
rownames(top25_1) <- NULL
colnames(top25_1) <- c("subreddit","comments","rank")
save(top25_1, file = "top25_1.RData")


counts2 = data.frame(key = sapply(user_February,get_val,i=1),
             value = sapply(user_February,get_val,i=2), stringsAsFactors=FALSE)
sort2 <- counts2[with(counts2,order(value,decreasing = TRUE)),]
sort2 <- data.frame(sort2,rank=1:nrow(sort2))
top25_2 <- head(sort2,25)
top25_2 = merge(top25_2,sort1,by = "key",all.x = TRUE,all.y = FALSE)
top25_2 = top25_2[with(top25_2, order(value.x,decreasing = TRUE)), ]
colnames(top25_2) <- c("subreddit","this month", "rank",
                       "last month","last rank")
rownames(top25_2) <- NULL 
top25_2 <- data.frame(top25_2, rank.increase =
                        top25_2[,5]-top25_2[,3])
save(top25_2, file = "top25_2.RData")



counts3 = data.frame(key = sapply(user_March,get_val,i=1),
               value = sapply(user_March,get_val,i=2), stringsAsFactors=FALSE)
sort3 <- counts3[with(counts3,order(value,decreasing = TRUE)),]
sort3 <- data.frame(sort3,rank=1:nrow(sort3))
top25_3 <- head(sort3,25)
top25_3 = merge(top25_3,sort2,by = "key",all.x = TRUE,all.y = FALSE)
top25_3 = top25_3[with(top25_3, order(value.x,decreasing = TRUE)), ]
colnames(top25_3) <- c("subreddit","this month", "rank",
                       "last month","last rank")
rownames(top25_3) <- NULL 
top25_3 <- data.frame(top25_3, rank.increase =
                        top25_3[,5]-top25_3[,3])
save(top25_3, file = "top25_3.RData")



counts4 = data.frame(key = sapply(user_April,get_val,i=1),
              value = sapply(user_April,get_val,i=2), stringsAsFactors=FALSE)
sort4 <- counts4[with(counts4,order(value,decreasing = TRUE)),]
sort4 <- data.frame(sort4,rank=1:nrow(sort4))
top25_4 <- head(sort4,25)
top25_4 = merge(top25_4,sort3,by = "key",all.x = TRUE,all.y = FALSE)
top25_4 = top25_4[with(top25_4, order(value.x,decreasing = TRUE)), ]
colnames(top25_4) <- c("subreddit","this month", "rank",
                       "last month","last rank")
rownames(top25_4) <- NULL 
top25_4 <- data.frame(top25_4, rank.increase =
                        top25_4[,5]-top25_4[,3])
save(top25_4, file = "top25_4.RData")



counts5 = data.frame(key = sapply(user_May,get_val,i=1),
              value = sapply(user_May,get_val,i=2), stringsAsFactors=FALSE)
sort5 <- counts5[with(counts5,order(value,decreasing = TRUE)),]
sort5 <- data.frame(sort5,rank=1:nrow(sort5))
top25_5 <- head(sort5,25)
top25_5 = merge(top25_5,sort4,by = "key",all.x = TRUE,all.y = FALSE)
top25_5 = top25_5[with(top25_5, order(value.x,decreasing = TRUE)), ]
colnames(top25_5) <- c("subreddit","this month", "rank",
                       "last month","last rank")
rownames(top25_5) <- NULL 
top25_5 <- data.frame(top25_5, rank.increase =
                        top25_5[,5]-top25_5[,3])
save(top25_5, file = "top25_5.RData")
