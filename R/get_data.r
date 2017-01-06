#' SQL query that fetches the notification settings data from Redshift.
#'
#' A string containing a SQL query that fetches the notification settings data
#' from Redshift.
#'
#' @format A length-one character vector
"notification_click_query"

#' Tidied results
#' 
#' Contains the most recent tidied results of
#' tidy_notification_click_data.
#'
#' @format A data.frame
"tidy_results"

#' Function that runs the notification_settings_query and returns the results
#' as a data.frame.
#'
#' @param con A database connection object.
#' @import RPostgreSQL
#' @import DBI
get_notification_click_data <- function(con){
  dbGetQuery(conn = con
             , statement = notificationGraphs::notification_click_query)
}

#' Tidy the data obtained from SQL.
#'
#' @param clickData The result of calling get_notification_click_data().
#' @importFrom tidyr gather
tidy_notification_click_data <- function(clickData){
  tidyr::gather(data = clickData
                , key = variable
                , value = click_count
                , click_count:manage_count_same_week)
}

#' Filter the tidy data.
#'
#' @param tidyData The result of calling tidy_notification_click_data.
#' @param event_types A character vector listing the event types to include in
#' the final chart.
#' @param date_range A length-two Date vector containing the min and max date
#' to include in the filtered dataset.
#' @param variable A length-one character vector specifying the variable whose
#' value will be displayed in the final chart. Can be set to "click",
#' "unsubscribe", or "manage".
#' @importFrom dplyr mutate
filter_tidy_data <- function(tidyData
                             , event_types
                             , date_range
                             , variable){
  full_variable <- paste0(variable, "_count_same_week")
  tidyData[
    tidyData$event_type %in% event_types
    & tidyData$sent_week_start_date >= min(date_range)
    & tidyData$sent_week_start_date <= max(date_range)
    & tidyData$variable == full_variable
    ,
  ]  
}

#' Postprocess the tidy data for plotting the final line chart.
#'
#' @param filteredData The result of calling filter_tidy_data.
#' @param aggregate Logical. Should the results for separate event types be
#' plotted individually (F), or in aggregate (T)?
#' @import dplyr
postprocess <- function(filteredData
                        , aggregate){
  groupedData <- if(!aggregate){
    dplyr::group_by(filteredData
                    , sent_week_start_date
                    , event_type
                    , variable)
  } else {
    dplyr::group_by(filteredData
                    , sent_week_start_date
                    , variable)
  }

  out <- dplyr::summarise(groupedData
                   , click_rate = sum(click_count)/sum(notification_count))
  dplyr::ungroup(out)
}

#' Plot the postprocessed data.
#'
#' @param processedData The result of calling postprocess.
#' @import ggplot2
#' @importFrom scales percent
#' @importFrom ggthemes theme_tufte
generate_final_plot <- function(processedData){
  aggregate <- ncol(processedData) == 3
  Map <- if(aggregate){
    aes_string(x = "sent_week_start_date"
              , y = "click_rate")
  } else {
    aes_string(x = "sent_week_start_date"
              , y = "click_rate"
              , colour = "event_type")
  }

  out <- ggplot(processedData
         , mapping = Map) +
    geom_line() +
    scale_y_continuous(labels = scales::percent) +
    ggthemes::theme_tufte(base_size = 16) 

  if(aggregate){
    return(out)
  } else {
    return(
      out + guides(colour=guide_legend(title = "Event Type"))
    )
  }
}

#' Convert tidy data to plot.
#'
#' @param tidyData The result of calling tidy_notification_click_data.
#' @param input A list containing elements named "chart_type", "event_types",
#' "date_range", and "variable". These correspond to the input list generated
#' by the ui.r Shiny script.
#' @export
convert_tidy_to_plot <- function(tidyData
                                 , input){
    generate_final_plot(
      postprocess(
        aggregate = input$chart_type==1
        , filter_tidy_data(
            tidyData
            , event_types = unlist(input$event_types)
            , date_range = input$date_range
            , input$variable
          )
      )
    )
}

#' Extract the legend from a ggplot.
#'
#' @param gplot A ggplot object.
#' @importFrom ggplot2 ggplot_gtable
#' @importFrom ggplot2 ggplot_build
#' @export
extract_legend <- function(gplot){
  tmp <- ggplot2::ggplot_gtable(ggplot2::ggplot_build(gplot)) 
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
  legend <- tmp$grobs[[leg]] 
  return(legend)
}
