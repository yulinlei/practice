library(shiny)

city_list = c("HAMILTON","SAN FRANCISCO","NEW YORK",       
              "HONOLULU","WASHINGTON","BROOKLYN",       
              "ANCHORAGE","SEATTLE","STAMFORD",       
              "CLEVELAND","PHILADELPHIA","HARTFORD",       
              "PITTSBURGH","FAIRFAX","BOSTON",         
              "OAKLAND","MIAMI","BELLINGHAM",     
              "WEST PALM BEACH","ASHEVILLE","EDMONTON",       
              "HOUSTON","OSHAWA","HALIFAX",        
              "LAS VEGAS","FORT LAUDERDALE","SAN JOSE",      
              "GRAND RAPIDS","SAINT LOUIS","CHICAGO",        
              "CINCINNATI","ORLANDO","SACRAMENTO",     
              "BALTIMORE","ST.CATHARINES","CALGARY",        
              "SURREY","TORONTO","MADISON",      
              "MINNEAPOLIS","BUFFALO","PORTLAND",       
              "LOS ANGELES","JACKSONVILLE","CHARLOTTE",      
              "IRVINE","ATLANTA","DENVER",         
              "REGINA","BRAMPTON","QUEBEC CITY",    
              "AUSTIN","SAN DIEGO","HUNTSVILLE",     
              "RALEIGH","MILWAUKEE","GREENVILLE",     
              "COLUMBUS","FRESNO","TAMPA",         
              "VANCOUVER","DALLAS","VICTORIA",       
              "MONTREAL","FREDERICTON","RENO",           
              "WINDSOR","KANSAS CITY","NANAIMO",        
              "PHOENIX","ANN ARBOR","SAN ANTONIO",    
              "ROCHESTER","SPOKANE","MISSISSAUGA",    
              "FORT MYERS","ABBOTSFORD","OTTAWA",         
              "NEW ORLEANS","SHERBROOKE","OKLAHOMA CITY",  
              "RED DEER","LONDON","WINNIPEG",       
              "INDIANAPOLIS","MEMPHIS","LOUISVILLE",     
              "DETROIT","TUCSON","KELOWNA",        
              "AKRON","ALBUQUERQUE","KITCHENER",      
              "SALT LAKE CITY","BOISE","IOWA CITY")
major <- c("MISC","CONCERTS","FAMILY","ARTS","SPORTS","MOVIES")
minorMISC <- c("SPECIAL ENTRY (UPSELL)","CONCESSION VOUCHERS (UPSELL)","BUS/TRANSPORTATION","OTHER","LECTURE/SEMINAR","MERCHANDISE VOUCHERS(UPSELL)","CLUB ACCESS","DINNER PACKAGES (UPSELL)","COMPETITION","PARTY/GALA","CONCESSION VOUCHERS","FOOD/WINE","TEST EVENT")
minorCONCERTS <- c("ADULT CONTEMPORARY", "ROCK/POP", "COMEDY", 
                   "ALTERNATIVE ROCK", "LATIN MUSIC", "POP", "FOLK" , 
                   "CLASSICAL/VOCAL", "BLUEGRASS", "COUNTRY", "DANCE MUSIC/DANCE",
                   "HEAVY METAL", "JAZZ", "R & B ", "TRIBUTE BAND", 
                   "ETHNIC/FOREIGN", "FESTIVALS" , "OTHER" , "RAP/URBAN" , 
                   "SOUL" , "PUNK" , "GOSPEL" , "REGGAE" , "CHILDREN" , "FUNK" ,
                   "BLUES" , "REGGAETON" , "NEW AGE" , "CHANSON FRANCAISE" ,
                   "AWARD CEREMONY","ELECTRONIC/DANCE CLUB-MFX ONLY" ,
                   "OLDIES" , "DRUM & BASS/DUBSTEP/GRIME CLUB-MFX ONLY" ,
                   "BALLADS/ROMANTIC")
minorFAMILY <- c("OTHER","CHILDREN'S THEATRE","MAGIC SHOWS")
minorARTS <- c("BALLET/DANCE", "THEATRE (COMEDY)" , "OTHER" , "PERFORMANCE ART" , "THEATRE OTHER" , "CLASSICAL/SYMPHONIC" , "CABARET" , "MAGIC" , "THEATRE (MUSICAL)" , "CLASSICAL/VOCAL" , "THEATRE (DRAMA)" , "SPECTACULAR SHOWS" , "FASHION/PAGEANT","CIRCUS ")
minorSPORTS <- c("WRESTLING" , "OTHER" , "BOXING" , "FAN EXPERIENCES" , "SOCCER")
minorMOVIES <- c("OTHER")
month_choice = c("January"=1,"February"=2,"March"=3,
"April"= 4,"May"=5,"June"=6,"July"=7,"August"=
 8,"September"= 9,"October"= 10,"November"=11,"December"=12)

shinyUI(
  fluidPage(
    titlePanel(
      "Suggested Ticket Price"
    ),
    sidebarPanel(
      h4("Conditions:"),
      selectInput("city", "City List:", city_list),
      selectInput("month_choice", "Month:", month_choice),
      selectInput("major", "Event Major Category:",major),
      hr(),
      h4("Minor Category:"),
      conditionalPanel(
        condition = "input.major == 'MISC'",
        selectInput("minor","Event Minor Category:",minorMISC)
      ),
      conditionalPanel(
        condition = "input.major == 'CONCERTS'",
        selectInput("minor","Event Minor Category:",minorCONCERTS)
      ),
      conditionalPanel(
        condition = "input.major == 'FAMILY'",
        selectInput("minor","Event Minor Category:",minorFAMILY)
      ),
      conditionalPanel(
        condition = "input.major == 'ARTS'",
        selectInput("minor","Event Minor Category:",minorARTS)
      ),
      conditionalPanel(
        condition = "input.major == 'SPORTS'",
        selectInput("minor","Event Minor Category:",minorSPORTS)
      ),
      conditionalPanel(
        condition = "input.major == 'MOVIES'",
        selectInput("minor","Event Minor Category:",minorMOVIES)
      ),
      actionButton("go", "Let's Search!")
    ),
    mainPanel(
      plotOutput("map", height = 450, width = 700),
      h4("Suggested Ticket Price:"),
      verbatimTextOutput("ticketprice")
    )
  )
)
