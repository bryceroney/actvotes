library(here)
library(readr)
library(stringr)
library(sf)
library(dplyr)
library(tidyr)

raw_data <- read_csv(here('data-raw/polling_places_raw.csv'))

data_tidy <- raw_data %>%
  select(Name, Coordinates, Polling_area) %>%
  mutate(c = str_extract_all(Coordinates, '[-[0-9.]+]+')) %>%
  unnest_wider(c, names_sep='_') %>%
  rename(lat = c_1, lng = c_2) %>%
  mutate(lat = as.numeric(lat), lng=as.numeric(lng)) %>%
  select(-Coordinates)

crs_string <- 'PROJCS["WGS 84 / Pseudo-Mercator",
    GEOGCS["WGS 84",
        DATUM["WGS_1984",
            SPHEROID["WGS 84",6378137,298.257223563,
                AUTHORITY["EPSG","7030"]],
            AUTHORITY["EPSG","6326"]],
        PRIMEM["Greenwich",0,
            AUTHORITY["EPSG","8901"]],
        UNIT["degree",0.0174532925199433,
            AUTHORITY["EPSG","9122"]],
        AUTHORITY["EPSG","4326"]],
    PROJECTION["Mercator_1SP"],
    PARAMETER["central_meridian",0],
    PARAMETER["scale_factor",1],
    PARAMETER["false_easting",0],
    PARAMETER["false_northing",0],
    UNIT["metre",1,
        AUTHORITY["EPSG","9001"]],
    AXIS["X",EAST],
    AXIS["Y",NORTH],
    EXTENSION["PROJ4","+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"],
    AUTHORITY["EPSG","3857"]]'

act_polling_places_2020 <- data_tidy %>%
  st_as_sf(coords=c('lng', 'lat'), crs=crs_string)


usethis::use_data(act_polling_places_2020, overwrite=TRUE)
