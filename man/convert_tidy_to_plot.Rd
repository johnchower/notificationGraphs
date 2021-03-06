% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_data.r
\name{convert_tidy_to_plot}
\alias{convert_tidy_to_plot}
\title{Convert tidy data to plot.}
\usage{
convert_tidy_to_plot(tidyData, input)
}
\arguments{
\item{tidyData}{The result of calling tidy_notification_click_data.}

\item{input}{A list containing elements named "chart_type", "event_types",
"date_range", and "variable". These correspond to the input list generated
by the ui.r Shiny script.}
}
\description{
Convert tidy data to plot.
}

