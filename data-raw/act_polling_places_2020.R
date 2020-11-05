library(here)
library(readr)
library(stringr)
library(sf)

raw_data <- read_csv(here('data-raw/polling_places_raw.csv'))

data_tidy <- raw_data %>%
  select(Name, Coordinates, Polling_area) %>%
  mutate(c = str_extract_all(Coordinates, '[-[0-9.]+]+')) %>%
  unnest_wider(c, names_sep='_') %>%
  rename(lat = c_1, lng = c_2) %>%
  mutate(lat = as.numeric(lat), lng=as.numeric(lng)) %>%
  select(-Coordinates)

act_polling_places_2020 <- data_tidy %>%
  st_as_sf(coords=c('lng', 'lat'), crs=3857)


usethis::use_data(act_polling_places_2020)
