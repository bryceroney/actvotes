library(here)
library(curl)
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)


urls <- c("https://www.elections.act.gov.au/elections_and_voting/2020_legislative_assembly_election/distribution-of-preferences-2020/table2_brindabella.xlsx",
          "https://www.elections.act.gov.au/elections_and_voting/2020_legislative_assembly_election/distribution-of-preferences-2020/table2_ginninderra.xlsx",
          "https://www.elections.act.gov.au/elections_and_voting/2020_legislative_assembly_election/distribution-of-preferences-2020/table2_kurrajong.xlsx",
          "https://www.elections.act.gov.au/elections_and_voting/2020_legislative_assembly_election/distribution-of-preferences-2020/table2_murrumbidgee.xlsx",
          "https://www.elections.act.gov.au/elections_and_voting/2020_legislative_assembly_election/distribution-of-preferences-2020/table2_yerrabi.xlsx")

getPreferencesForPage <- function(url) {
  regex <- "(?<=https://www.elections.act.gov.au/elections_and_voting/2020_legislative_assembly_election/distribution-of-preferences-2020/table2_)([a-z])*"
  elec_name <- str_extract(url, regex) %>% str_to_title()

  print(elec_name)

  curl::curl_download(url,
                      destfile = here('data-raw/tmp.xlsx'))

  data <- read_excel(here('data-raw/tmp.xlsx'), skip = 2)


  output <- data %>%
    select(-tail(names(.), 2)) %>%
    rename(count = ...1,
           exhausted = names(.)[length(names(.))-1],
           loss_by_fraction = names(.)[length(names(.))]) %>%
    mutate(type = ifelse(is.na(count), 'Distribution', 'Final')) %>%
    fill(count, .direction='up') %>%
    pivot_longer(!count & !type,
                 names_to = 'name',
                 values_to = 'votes') %>%
    mutate(name = str_replace(name, '- [A-Za-z ]*', ''),
           last_name = str_extract(name, '([A-Z]{2,}[A-Z-]*)'),
           first_name = str_replace(name, paste0(' ', last_name), ''),
           ballot_paper_name = paste0(last_name, ', ', first_name),
           name = ifelse(name %in% c('loss_by_fraction', 'exhausted'), name, ballot_paper_name)) %>%
    select(count:votes) %>%
    mutate(electorate = elec_name)

  output

}

act_preferences_2020 <- map_dfr(urls, getPreferencesForPage)

usethis::use_data(act_preferences_2020, overwrite = TRUE)
