library(rvest)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)

url <- "https://www.elections.act.gov.au/elections_and_voting/2020_legislative_assembly_election/list-of-candidates"

# Load our raw data
page_raw <- read_html(url)
rows <- html_nodes(page_raw, css = "#body-main") %>%
  html_nodes("h2,h3,ul")

rows <- rows[5:length(rows)]

# Set global functions for loop,
# there is probably a better way to do this in R
elec_name <- "NA"
party_name <- "NA"

act_candidates_2020 <- rows %>%
  map_dfr(function(x) {
    if (html_name(x) == "h2") {
      elec_name <<- html_text(x)
    }
    if (html_name(x) == "h3") {
      party_name <<- html_text(x)
    }
    if (html_name(x) == "ul") {
      data.frame(
        candidate = x %>% html_nodes("li") %>% html_text(),
        party = party_name,
        electorate = elec_name
      )
    }
  }) %>%
  tibble()

act_candidates_2020 <- act_candidates_2020 %>%
  filter(!str_detect(candidate, "printable list")) %>%
  mutate(party = ifelse(party == 'UNGROUPED',
                         ifelse(candidate == 'Mohammad Munir HUSSAIN - Australian Federation Party Australian Capital Territory', 'Australian Federation Party Australian Capital Territory', 'Independent'),
                         str_extract(party, '(?<=[A-Z]\\) )([A-Za-z ])+')),
         candidate = str_replace(candidate, '- [A-Za-z ]*', ''),
         last_name = str_extract(candidate, '([A-Z]{2,}[A-Z-]*)'),
         first_name = str_replace(candidate, paste0(' ', last_name), ''),
         ballot_paper_name = paste0(last_name, ', ', first_name)) %>%
  mutate(party = factor(party)) %>%
  select(-candidate)


usethis::use_data(act_candidates_2020, overwrite=TRUE)
