library(dplyr)
library(plotly)
function(input, output){
  tidyData <- notificationGraphs::tidy_results   
  mindate <- min(tidyData$sent_week_start_date)
  maxdate <- max(tidyData$sent_week_start_date)

  output$plot <- renderPlotly({
    notificationGraphs::convert_tidy_to_plot(tidyData
                         , input) +
    theme(
      legend.position = "none"
      , 
      axis.title = element_blank()
    )
  })
  output$legend <- renderPlot({
    if(input$chart_type == 1) {
    } else {
    notificationGraphs::convert_tidy_to_plot(tidyData
                         , input) %>%
      {notificationGraphs::extract_legend(.)} %>%
      {grid::grid.draw(.)}
    }
  })
}
