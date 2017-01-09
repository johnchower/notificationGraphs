proj_root <- rprojroot::find_root(rprojroot::has_dirname('notificationGraphs'))
path_to_query <- 'inst/queries/notificationQueries.sql'
full_path_to_query <- paste(proj_root, path_to_query, sep = '/')

notification_click_query <- readLines(con = full_path_to_query)
notification_click_query <- paste(notification_click_query, collapse=" ")

devtools::use_data(notification_click_query
                   , overwrite = T
                   , pkg = proj_root)

devtools::load_all(pkg = proj_root)
glootility::connect_to_redshift()

  notification_clicks <- 
    get_notification_click_data(con = redshift_connection$con) 

  tidy_results <- tidy_notification_click_data(notification_clicks)

  RPostgreSQL::dbDisconnect(redshift_connection$con)
devtools::use_data(tidy_results
                   , overwrite = T
                   , pkg = proj_root)

commit_message <- paste0("'Update data and query "
                         , Sys.time()
                         , "'")
command  <- 
  paste0(
    "cd "
    , proj_root
    , "&& "
    , "git add data/notification_click_query.rda data/tidy_results.rda "
    , "&& "
    , "git commit -m "
    , commit_message
    , "&& "
    , "git push"
  )

system(command)
