#' SQL query that fetches the notification settings data from Redshift.
#'
#' A string containing a SQL query that fetches the notification settings data
#' from Redshift.
#'
#' @format A length-one character vector
"notification_click_query"

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
#' to include in the final chart.
#' @param variable A length-one character vector specifying the variable whose
#' value will be displayed in the final chart. Can be set to "click",
#' "unsubscribe", or "manage".
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

  ggplot(processedData
         , mapping = Map) +
  geom_line()
}
