proj_root <- rprojroot::find_root(rprojroot::has_dirname('notificationGraphs'))
path_to_query <- 'inst/queries/notificationQueries.sql'
full_path_to_query <- paste(proj_root, path_to_query, sep = '/')

notification_click_query <- readLines(con = full_path_to_query)
notification_click_query <- paste(notification_click_query, collapse=" ")

devtools::use_data(notification_click_query
                   , overwrite = T
                   , pkg = proj_root)
