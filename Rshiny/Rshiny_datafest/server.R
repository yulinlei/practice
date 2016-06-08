library(geosphere)
library(ggplot2)
library(ggmap)
library(glmnet)
library(MASS)

load("location.Rdata")
load("event_final.Rdata")
shinyServer(
  function(input, output)
  {
    event_final=event_final[event_final$cat!="MISC,PARKING",]
    m2 <- rlm(log(num_ticket) ~ factor(month) + index + cat + poly(trans_face_val_amt,2), data =event_final)
    best_price<-function(m,s){
      coef=coef(m)
      n=length(coef)
      sc=rep(0,n)
      if(s[1]!=1)
        sc[as.numeric(s[1])]=1
      sc[1]=1
      sc[13]=as.numeric(s[2])
      if(paste("cat",s[3],sep = "")!="catARTS,BALLET/DANCE")
      {sc[which(names(coef)==paste("cat",s[3],sep = ""))]=1}
      a=0.01^2*coef[n]
      b=0.01*coef[n-1]
      c=(sum(sc[1:(n-2)]*coef[1:(n-2)]))
      price=-(2*a+b+sqrt((2*a+b)^2-4*a*(b+c)))/(2*a)
      return (as.numeric((price/10+1-round(as.numeric(price/10)))*1000-500)*0.25)
    }
    
    pred_price = reactive({
        best_price(m2,c(input$month_choice,location[location$city==input$city,][4],
    paste0(input$major,",",input$minor)))}
    )
    
    output$map = renderPlot(
      {
        USmap <- get_map(location=c(lon = -96, lat = 40), zoom = 4, maptype = "terrain")
        ggmap(USmap) +  geom_point(aes(x=longitude , y=latitude), data=location[location$city==input$city,], 
        col="orange",alpha=0.6, size=pred_price()/8) + scale_size_continuous(range=range(pred_price())/8)
      }
    )
    output$ticketprice = renderText(
      {pred_price()}
    )
  }
)
