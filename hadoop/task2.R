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
      key = fromJSON(map.values[[r]])$created_utc
      value = 1
      rhcollect(key,value)
    }
  )
})

## January
user_time = rhwatch(
  map      = user_map,
  reduce   = user_reduce,
  input    = rhfmt("/data/RC_2015-01.json", type = "text")
)

get_val = function(x,i) x[[i]]
counts_time = data.frame(key = sapply(user_time,get_val,i=1),
                     value = sapply(user_time,get_val,i=2), stringsAsFactors=FALSE)
library(lubridate)
date <- as.character(.POSIXct(counts_time$key))
date <- ymd_hms(date)
day <- day(date)
hour <- hour(date)
counts_time <- data.frame(counts_time,date=paste0(day,".",hour))
save(counts_time,file = "counts_time.Rdata")


days = day(date)
hours = hour(date)
library(dplyr)

res3 = data.frame(counts_time,days, hours)

head(res3)

res3 = res3%>%arrange(days,hours)

date_index <- unique(res3$date)
countdata <- rep(0,length(date_index))
for(i in 1:length(countdata))
  countdata[i] <- sum(res3$value[which(res3$date==date_index[i])])

save(countdata,file="countdata.Rdata")
plot(countdata, type="l")


#### calc which week #####
res3$weekdays = wday(date, label=T)
res3$wkey = paste0(res3$weekdays,".",res3$hours)
res3 = res3%>%arrange(weekdays,hours)


date_index2 <- unique(res3$wkey)
countdata2 <- rep(0,length(date_index2))
for(i in 1:length(countdata2))
  countdata2[i] <- sum(res3$value[which(res3$wkey==date_index2[i])])

countdata2 <- data.frame(countdata2,date_index2)
save(countdata2,file="countdata2.Rdata")
# 1.
mondata1 = countdata2 %>% filter(str_match(countdata2$date_index2, ".*\\.") == "Mon.")
plot(mondata1$countdata2, type="l",main="Monday")

#2.
tuesdata1 = countdata2 %>% filter(str_match(countdata2$date_index2, ".*\\.") == "Tues.")
plot(tuesdata1$countdata2, type="l",main="Tuesday")

# 3.
weddata1 = countdata2 %>% filter(str_match(countdata2$date_index2, ".*\\.") == "Wed.")
plot(weddata1$countdata2, type="l",main="Wednesday")


# 4.
thursdata1 = countdata2 %>% filter(str_match(countdata2$date_index2, ".*\\.") == "Thurs.")
plot(thursdata1$countdata2, type="l",main="Thursday")

# 5.
fridata1 = countdata2 %>% filter(str_match(countdata2$date_index2, ".*\\.") == "Fri.")
plot(fridata1$countdata2, type="l",main="Friday")

# 6.
satdata1 = countdata2 %>% filter(str_match(countdata2$date_index2, ".*\\.") == "Sat.")
plot(satdata1$countdata2, type="l",main="Saturday")


# 7.
sundata1 = countdata2 %>% filter(str_match(countdata2$date_index2, ".*\\.") == "Sun.")
plot(sundata1$countdata2, type="l",main="Sunday")



