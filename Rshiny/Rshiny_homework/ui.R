library(shiny)
library(parallel)

total_priors = c("Binomial" = "binom", "Negative Binomial" = "nbinom")
prop_priors = c("Beta" = "beta", "Truncated Normal"="tnorm")

shinyUI(
  fluidPage(
    titlePanel(
      "Karl Broman Socks"
    ),
    sidebarPanel(
      numericInput("n_sims", h4("Simulations:"),value = 10000, min = 5000, step = 1),
      hr(),
      h4("Data:"),
      sliderInput("n_unique", "Number unique:", min=1, max=8, value=4, step=1),
      sliderInput("n_pairs", "Number pairs:", min=0, max=6, value=3, step=1),
      hr(),
      checkboxInput(inputId = "summary",
                    label = strong("Show summary"),
                    value = FALSE),   
      hr(),
      checkboxInput(inputId = "table",
                    label = strong("Show table"),
                    value = FALSE), 
      hr(),
      h4("Priors:"),
      selectInput("total_prior", "Prior for total", total_priors),
      selectInput("prop_prior", "Prior for proportion", prop_priors),
      hr(),
      h4("Hyperparameters:"),
      conditionalPanel(
        condition="input.total_prior == 'binom'",
        sliderInput("total_n",HTML("Total prior - n;"), value = 150, min=100, max=200),
        sliderInput("total_pbinom",HTML("Total prior - p;"), value = .6, min=0.4, max=1)
      ),
      conditionalPanel(
        condition="input.total_prior == 'nbinom'",
        numericInput("total_r",HTML("Total prior - r"), value = 150, min=100, max=200),
        numericInput("total_p",HTML("Total prior - p"), value = 0.5, min=0.3, max=1)
      ),
      conditionalPanel(
        condition="input.prop_prior == 'beta'",
        numericInput("prop_alpha",HTML("Total prior - &alpha;"), value = 1 , min=0, max=NA),
        numericInput("prop_beta",HTML("Total prior - &beta;"), value = .5, min=0, max=NA)
      ),
      conditionalPanel(
        condition="input.prop_prior == 'tnorm'",
        numericInput("prop_mu",HTML("Proportion prior - &mu;"), value = 0.5, min=0.3, max=NA),
        numericInput("prop_sigma",HTML("Proportion prior - &sigma;"), value = 0.1, min=0, max=NA)
      )
    ),
    mainPanel(
      h4("Results:"),
      plotOutput("prior_plot"),
      br(),
      plotOutput("post_plot"),
      br(),
      tableOutput("post_table")
    )
  )
)
