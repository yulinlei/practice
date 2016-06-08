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



### Word Count Example

dailyWordCounter = function(month1, day1, file)
{
  wc_reduce = expression(
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
  
  
    wc_map = expression({
      suppressMessages(library(jsonlite))
      suppressMessages(library(stringr))
      suppressMessages(library(dplyr))
      suppressMessages(library(lubridate))
      
      lapply(
        seq_along(map.keys), 
        function(r) 
        {
          key = fromJSON(map.values[[r]])$body
          date = fromJSON(map.values[[r]])$created_utc
          date = as.character(.POSIXct(date))
          date = ymd_hms(date)
          month = month(date)
          day = day(date)
          
          if(month %in% 1:12)
          {
            if(day == day1 & month == month1)
            {
             line = tolower(key)
             line = gsub("[-—]"," ",line)
             line = gsub("[^'`’[:alpha:][:space:]]","",line,perl=TRUE)
             line = gsub("(^\\s+|\\s+$)","",line)
             line = str_trim(line)
             line = strsplit(line, "\\s+")[[1]]
             line = line[line != ""]
                    
             lapply(line, rhcollect, value=1)
             #lapply(key, rhcollect, value=1)
             #lapply(month, rhcollect, value=1)
            }
          }
        }
      )
    })
    
    
    wc = rhwatch(
      map      = wc_map,
      reduce   = wc_reduce,
      input    = rhfmt(file, type = "text")
    )
  
  
  get_val = function(x,i) x[[i]]
  
  counts = data.frame(key = sapply(wc,get_val,i=1),value = sapply(wc,get_val,i=2), stringsAsFactors=FALSE)
  counts = counts[order(counts$value, decreasing=TRUE), ]
  return(counts)
}



month1 = 2
day1 = 14
file = "/data/RC_2015-02.json"

# function that counts words for the day we want
Feb14 = dailyWordCounter(month1, day1, file)
save(Feb14, file = "Feb14.Rdata")

month1 = 1
day1 = 1
file = "/data/RC_2015-01.json"

Jan1 = dailyWordCounter(month1, day1, file)
save(Jan1, file = "Jan1.Rdata")

#month1 = 5
#day1 = 5
#file = "/data/RC_2015-05.json"

#May5 = dailyWordCounter(month1, day1, file)
 

library(dplyr)
library(rowr)
library(tm)
library(stringr)
library(ggplot2)

# function that produces a df that compares word counts among days
comparison = function(date1, date2)
{
  
  # cleaning up our daily word counts
  date1 = date1 %>%
    mutate(key = as.character(key),
           value = as.numeric(as.character(value)),
           rank = 1:nrow(date1))
  date2 = date2 %>%
    mutate(key = as.character(key),
           value = as.numeric(as.character(value)),
           rank = 1:nrow(date2))
  
  stopwords = stopwords(kind = "en") # stopword to remove
  
  date1 = date1 %>%
    filter(!(key %in% stopwords))
  date2 = date2 %>%
    filter(!(key %in% stopwords))
  
  # combining our days into one dataframe
  both = cbind.fill(date1, date2, fill="99999")
  colnames(both) = c("key1", "value1", "rank1", "key2", "value2", "rank2")
  both = both %>%
    mutate(key1 = str_trim(as.character(key1)),
           value1 = as.numeric(as.character(value1)),
           rank1 = as.numeric(as.character(rank1)),
           key2 = str_trim(as.character(key2)),
           value2 = as.numeric(as.character(value2)),
           rank2 = as.numeric(as.character(rank2)))
  
  
  # finding those words from day one that are not ranked within 10 of
  # the same word in the other day
  difference1 = as.data.frame(matrix(NA, nrow = 1000, ncol=3))
  names(difference1)= names(both)[1:3]
  for(i in 1:1000)
  {
    if(!(both$key1[i] %in% both$key2))
    {
      difference1[i, ] = both[i, 1:3]
    } else if(!((both$value2[both$key2 == both$key1[i]] - 5000 < both$value1[i]) & 
          (both$value1[i] < both$value2[both$key2 == both$key1[i]] + 5000)))
    {
      difference1[i, ] = both[i, 1:3]
    }
  }
  
  difference1 = difference1 %>%
    filter(is.na(key1) == FALSE) %>%
    mutate(date = "Feb14")
  
  
  # finding those words from day two that are not ranked within 10 of
  # the same word in the other day
  #difference2 = as.data.frame(matrix(NA, nrow = 1000, ncol=3))
  #names(difference2)= names(both)[4:6]
  #for(i in 1:1000)
  #{
   # if(!(both$key2[i] %in% both$key1))
    #{
     # difference2[i, ] = both[i, 4:6]
    #} else if(both$key2[i] != both$key1[i] & 
    #          !((both$value1[both$key1 == both$key2[i]] - 5000 < both$value2[i]) & 
     #           (both$value2[i] < both$value1[both$key1 == both$key2[i]] + 5000)))
    #{
    #  difference2[i, ] = both[i, 4:6]
    #}
  #}
  
  # finding where the words in difference 1 appear in difference 2
  difference2 = as.data.frame(matrix(NA, nrow = 1000, ncol=3))
  names(difference2)= names(both)[1:3]
  for(i in 1:nrow(difference1))
  {
    difference2[i , ] = (both %>%
      filter(key2 == difference1$key1[i]))[, 4:6]
  }
  
  # removing NAs
  
  difference2 = difference2 %>%
    filter(is.na(key1) == FALSE) %>%
    mutate(date = "Jan1")
  
  # visualization
  difference = as.data.frame(bind_rows(difference1, difference2))
  return(difference)
}

x = comparison(date1 = Feb14, date2 = Jan1)
#y = comparison(date1 = Feb14, date2 = May5)

save(x, file = "Feb14_Jan1.Rdata")
#save(y, file = "day1_day3.Rdata")

library(wordcloud)

# removing stopwords

Feb14 = Feb14 %>%
  filter(!(key %in% stopwords))
Jan1 = Jan1 %>%
  filter(!(key %in% stopwords))

# wordcloud
wordcloud(words = Feb14$key, freq=Feb14$value, max.words=100, colors=brewer.pal(6, "Dark2"))

wordcloud(words = Jan1$key, freq = Jan1$value, max.words = 100, colors=brewer.pal(6, "Dark2"))
