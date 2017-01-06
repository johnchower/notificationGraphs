query_loc <- '~/Projects/notificationGraphs/inst/queries/notificationQueries.sql'

notification_click_query <- readLines(con = query_loc)
notification_click_query <- paste(notification_click_query, collapse=" ")

devtools::use_data(notification_click_query, overwrite = T)
devtools::load_all()
