library(truncnorm)

shinyServer(
  function(input, output)
  {
    priors = reactive(
      {
        n_socks = numeric()
        if (input$total_prior == "binom")
        {
          n_socks = rbinom(input$n_sims, input$total_n, input$total_pbinom)
        } else {
          n_socks = rnbinom(input$n_sims,size = input$total_r, prob = input$total_p)
        }

        prop_pairs = numeric()
        if (input$prop_prior == "beta")
        {
          prop_pairs = rbeta(input$n_sims, input$prop_alpha, input$prop_beta)
        } else {
          prop_pairs = rtruncnorm(input$n_sims,0,1,input$prop_mu,input$prop_sigma)
        }

        data.frame(total = n_socks, prop = prop_pairs)
        
      }
    )

    sock_sim = reactive(
      {
       prior = as.matrix(priors())
       prior = lapply(1:NROW(prior), function(i) prior[i,,drop=FALSE]) 
       
       gen_model = function(total,prop)
        {
         n_pairs <- round(floor(total / 2) * prop)
         n_odd <- total - n_pairs * 2
          # Simulating picking out n_picked socks
          socks <- rep(seq_len(n_pairs + n_odd), rep(c(2, 1), c(n_pairs, n_odd)))
          picked_socks <- sample(socks, size =  min(input$n_unique+2*input$n_pairs
                                                    ,total))
          sock_counts <- table(picked_socks)
          # Returning the parameters and counts of the number of matched
          # and unique socks among those that were picked out.
          result <- c(unique = sum(sock_counts == 1), pairs = sum(sock_counts == 2),
                      n_socks = total, n_pairs = n_pairs,
                      n_odd = n_odd, prop_pairs = prop)
          return(result)
       }
       #apply(priors(),1, function(x) gen_model(x[1],x[2]))
        #mclapply(1:10, function(x) rnorm(1e5), mc.cores = 5,, pvec(1:1e7, sqrt, mc.cores = 8)
        as.data.frame(mclapply(prior, function(x) gen_model(x[1], x[2]), mc.cores=4))
      }
    )

    

    posterior = reactive(
      {
         as.matrix(sock_sim()[,sock_sim()["unique",] == input$n_unique &
                      sock_sim()["pairs",] == input$n_pairs])
      }
    )

    output$prior_plot = renderPlot(
      {
        n_pairs <- round(floor(priors()[,1] / 2) * priors()[,2])
        n_odd <- priors()[,1] - n_pairs * 2
        par(mfrow=c(1,4))
        hist(priors()[,1], freq=FALSE, main="Prior on n_Socks", xlab= "Number of Socks", col="green")
        abline(v=mean(priors()[,1]), lty=2,col="red", lwd=2)
        hist(priors()[,2], freq=FALSE, main = "Prior on prop_pairs", xlab ="Proportion of socks in pairs", col="green")
        abline(v=mean(priors()[,2]), lty=2,col="red", lwd=2)
        hist(n_pairs, freq=FALSE, main="Resulting prior on n_pairs", xlab= "Number of sock pairs", col="green")
        abline(v=mean(n_pairs), lty=2,col="red", lwd=2)
        hist(n_odd, freq=FALSE, breaks = 5, main="Resulting prior on n_odd", xlab= "Number of odd socks",col="green")
        abline(v=mean(n_odd), lty=2,col="red", lwd=2)
      }
    )

    output$post_plot = renderPlot(
      {
        par(mfrow=c(1,4))
        hist(as.numeric(posterior()[3,]), freq=FALSE, main="Posterior on n_socks",xlab = "Number of Socks", col="lightblue")
        abline(v=mean(as.numeric(posterior()[3,])), lty=2,col="red", lwd=2)
        if (input$summary) {
        legend('topright',legend = c('mean',round(mean(as.numeric(posterior()[3,])),digits = 2),
                                     'median',round(median(as.numeric(posterior()[3,])),digits = 2),
                                     '95% CI',round(quantile(as.numeric(posterior()[3,]),
                                                             c(.025,.975)),digits = 2)))
        }

        hist(as.numeric(posterior()[6,]), freq=FALSE, main="Proportion on n_pairs", xlab ="Proportion of socks in pairs", col="lightblue")
        abline(v=mean(as.numeric(posterior()[6,])), lty=2,col="red", lwd=2)
        if (input$summary) {
        legend('topright',legend = c('mean',round(mean(as.numeric(posterior()[6,])),digits = 2),
                                     'median',round(median(as.numeric(posterior()[6,])),digits = 2),
                                     '95% CI',round(quantile(as.numeric(posterior()[6,]),
                                                             c(.025,.975)),digits = 2)))
         }

        hist(as.numeric(posterior()[4,]), freq=FALSE, main="Posterior on n_pairs", xlab="Number of sock pairs",col="lightblue")
        abline(v=mean(as.numeric(posterior()[4,])), lty=2,col="red", lwd=2)
        if (input$summary) {
        legend('topright',legend = c('mean',round(mean(as.numeric(posterior()[4,])),digits = 2),
                                     'median',round(median(as.numeric(posterior()[4,])),digits = 2),
                                     '95% CI',round(quantile(as.numeric(posterior()[4,]),
                                                             c(.025,.975)),digits = 2)))
        }

        hist(as.numeric(posterior()[5,]), freq=FALSE, main="Proportion on n_odd",xlab="Number of sock pairs", col="lightblue")
        abline(v=mean(as.numeric(posterior()[5,])), lty=2,col="red", lwd=2)
        if (input$summary) {
        legend('topright',legend = c('mean',round(mean(as.numeric(posterior()[5,])),digits = 2),
                                     'median',round(median(as.numeric(posterior()[5,])),digits = 2),
                                     '95% CI',round(quantile(as.numeric(posterior()[5,]),
                                                             c(.025,.975)),digits = 2)))}
        
        data1= reactive({
          data.frame(
            Names= c("Posterior on n_socks",
                     "Proportion on n_pairs",
                     "Posterior on n_pairs",
                     "Proportion on n_odd"),
            median=c(round(median(as.numeric(posterior()[3,]))),
                     round(median(as.numeric(posterior()[6,]))),
                     round(median(as.numeric(posterior()[4,]))),
                     round(median(as.numeric(posterior()[5,])))),
            
            mean=c(round(mean(as.numeric(posterior()[3,]),digits = 2)),
                   round(mean(as.numeric(posterior()[6,]),digits = 2)),
                   round(mean(as.numeric(posterior()[4,]),digits = 2)),
                   round(mean(as.numeric(posterior()[5,]),digits = 2))),
            
            lower=c(round(quantile(as.numeric(posterior()[3,]),.025,digits = 2)),
                    round(quantile(as.numeric(posterior()[6,]),.025,digits = 2)),
                    round(quantile(as.numeric(posterior()[4,]),.025,digits = 2)),
                    round(quantile(as.numeric(posterior()[5,]),.025,digits = 2))),
            
            upper=c(round(quantile(as.numeric(posterior()[3,]),.975,digits = 2)),
                    round(quantile(as.numeric(posterior()[6,]),.975,digits = 2)),
                    round(quantile(as.numeric(posterior()[4,]),.975,digits = 2)),
                    round(quantile(as.numeric(posterior()[5,]),.975,digits = 2))),
            stringsAsFactors = FALSE)
          
          
          
        })
        
        output$post_table <- renderTable({ 
          
          if (input$table) { 
            data1()
          }
        })
      }
      
    )
  }
)
