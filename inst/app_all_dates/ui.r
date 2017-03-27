library(plotly)

tidyData <- notificationGraphs::tidy_results   
mindate <- min(tidyData$sent_week_start_date)
maxdate <- max(tidyData$sent_week_start_date) # - 7
event_type_choices <- as.list(unique(tidyData$event_type))

fluidPage(
  titlePanel("Weekly Email Notification Click Rates")
  , sidebarPanel(
    radioButtons("variable"
                 , label = "Variable"
                 , choices = 
                  list("Click Rate" = "click"
                       , "Manage Rate" = "manage"
                       , "Unsubscribe Rate" = "unsubscribe")
                 , selected = "click"),
    radioButtons("chart_type"
                 , label = "Chart Type"
                 , choices = 
                  list("Aggregate" = 1
                       , "Individual" = 0)
                 , selected = 1),
    sliderInput("date_range"
                , label = "Date Range"
                , min = mindate
                , max = maxdate
                , step = 7
                , value = c(mindate, maxdate)),
    selectInput("event_types"
                , label = "Event Type"
                , choices = event_type_choices
                , multiple = T
                , selected = event_type_choices) 
  )
  , mainPanel(
    textOutput('text'),          
    plotlyOutput('plot'),
    plotOutput('legend')
  )
)
