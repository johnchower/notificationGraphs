function(input, output){
  tidyData <- notificationGraphs::tidy_results   
  mindate <- min(tidyData$sent_week_start_date)
  maxdate <- max(tidyData$sent_week_start_date)
  date_range <- c(as.Date('2016-12-05'), as.Date('2016-12-26'))
  event_types <- c('comment_on_post', 'connect_users', 'post_created')
  agg <- F

  output$plot <- renderPlot({
    notificationGraphs::generate_final_plot(
      notificationGraphs::postprocess(
        aggregate = input$chart_type==1
        , notificationGraphs::filter_tidy_data(
            tidyData
            , event_types = unlist(input$event_type)
            , date_range = input$date_range
            , input$variable
          )
      )
    )
  })
  output$text <- renderText({
    as.character(input$date_range)
  })
}
