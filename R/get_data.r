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
