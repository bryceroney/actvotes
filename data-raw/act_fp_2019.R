library(rvest)
library(dplyr)
library(stringr)
library(purrr)
library(urltools)

getResultsForPollingPlace <- function(url) {
  url <- paste0('https://www.electionresults.act.gov.au', url)
  url_regex <- "(?<=https://www.electionresults.act.gov.au/Results/PollingPlace\\?select=)[A-Za-z()%2089 ]+"
  polling_place_name <- str_extract(url, url_regex) %>% url_decode()

  print(glue::glue("Loading polling place: {polling_place_name}"))

  page_raw <- read_html(url)

  data <- page_raw %>%
    html_nodes(css = ".data-row") %>%
    html_nodes("td") %>%
    html_text(trim = TRUE)

  output <- data %>%
    matrix(ncol = 3, byrow = T) %>%
    tibble()

  output %>%
    transmute(
      candidate = .[, 1],
      votes = as.numeric(gsub(",", "", .[, 2])),
      polling_place= polling_place_name
  )
}

url <- "https://www.electionresults.act.gov.au/Results/PollingPlace"

page_raw <- read_html(url)

polling_place_urls <- page_raw %>%
  html_nodes(css='.data-row td:nth-child(2) a') %>%
  html_attr('href')


act_fp_2019 <- map_dfr(polling_place_urls, getResultsForPollingPlace)

usethis::use_data(act_fp_2019, overwrite = TRUE)
