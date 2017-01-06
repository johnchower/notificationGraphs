devtools::load_all()
glootility::connect_to_redshift()

  notification_clicks <- 
    get_notification_click_data(con = redshift_connection$con) 

  tidy_results <- tidy_notification_click_data(notification_clicks)

  RPostgreSQL::dbDisconnect(redshift_connection$con)
devtools::use_data(tidy_results, overwrite = T)
