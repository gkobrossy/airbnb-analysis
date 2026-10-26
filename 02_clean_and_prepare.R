# Airbnb Listing Analysis
# 02_clean_and_prepare.R
#
# Purpose:
# Clean the AirBNB data loaded from the previous script
#
# Data:
# Airbnb Listings in Major US Cities - Deloitte ML
#
# Author: George Kobrossy
# Date: 2026-09-19

library(tidyverse)
library(sf)

bnb_sample <- readRDS("data/bnb_sample.rds")
us_coastline <- readRDS("data/us_coastline.rds")

chi_entertainment_data <- readRDS("data/chi_entertainment.rds")
chi_culture_data <- readRDS("data/chi_culture.rds")
chi_transport_data <- readRDS("data/chi_transport.rds")
chi_park_data <- readRDS("data/chi_parks.rds")
source("config.R")

# Cleaning the AirBNB Data and Adding Additional Features -----------------
us_coastline <- st_transform(us_coastline, 4326)

bnb_sample_sf <- st_as_sf(bnb_sample, coords = c("longitude", "latitude"), crs = 4326)

bnb_sample_sf <- bnb_sample_sf |> 
  mutate(
    price = exp(log_price),
    host_year = year(host_since)
    ) |> 
  relocate(price, .before = log_price) |> 
  mutate(
    coast_distance = st_distance(geometry, us_coastline),
    coast_distance_km = (as.numeric(coast_distance)/1000)
  ) |> 
  mutate(
    clean_ammenities = str_replace_all(str_to_lower(amenities), "\"", "") |> 
      str_remove_all("\\{|\\}"), 
    ammenities_list = str_split(clean_ammenities, "\\s*,\\s*") |> 
      map(function(x) str_trim(x)),
    has_pool = map_lgl(ammenities_list, function(x) any(str_detect(x, "pools?")))
  ) |> 
  select(-clean_ammenities, -amenities)

saveRDS(
  bnb_sample_sf,
  file = "data/bnb_clean.rds"
)

# Cleaning OSM Data -------------------------------------------------------


clean_osm_data <- function(osm_layer, tag_column, tags, source_type = c("point", "polygon", "multipolygon", "lines"), crs = NULL){
  if(is.null(osm_layer)){
    return(NULL)
  }
  
  source_type <- match.arg(source_type)
  
  if (!is.null(crs)){
    osm_layer <- st_transform(osm_layer, crs = crs)
  }
  
  cleaned_data <- osm_layer |> 
    filter(.data[[tag_column]] %in% tags) |> 
    st_point_on_surface() |> 
    mutate(source = source_type) |> 
    select(
      any_of(c("osm_id", "name", "geometry", "source", tag_column, "bus", "subway", "train", "tram", "ferry", "railway")),
      starts_with("addr:")
    )
  
  return(cleaned_data)
}


aggregate_osm_data <- function(osm_dataset, tag_column, tags, crs = NULL){
  
  venue_points <- clean_osm_data(osm_dataset$osm_points, tag_column = tag_column, tags = tags, source_type = "point", crs = crs)
  venue_poly <- clean_osm_data(osm_dataset$osm_polygons, tag_column = tag_column, tags = tags, source_type = "polygon", crs = crs)
  venue_multipoly <- clean_osm_data(osm_dataset$osm_multipolygons, tag_column = tag_column, tags = tags, source_type = "multipolygon", crs = crs)
  venue_lines <- clean_osm_data(osm_dataset$osm_lines, tag_column = tag_column, tags = tags, source_type = "lines", crs = crs)
  city_venues <- bind_rows(
    venue_points,
    venue_poly,
    venue_multipoly,
    venue_lines
  )
  return(city_venues)
  
}

chi_entertainment_clean <- aggregate_osm_data(chi_entertainment_data, "amenity", entertainment_types, crs = 26916) 
chi_culture_clean <- aggregate_osm_data(chi_culture_data, "tourism", culture_types, crs = 26916) 
chi_transport_clean <- aggregate_osm_data(chi_transport_data, "public_transport", transport_types, crs = 26916) 

saveRDS(chi_entertainment_clean, "data/chi_entertainment_clean.rds")
saveRDS(chi_culture_clean, "data/chi_culture_clean.rds")
saveRDS(chi_transport_clean, "data/chi_transport_clean.rds")


# prepare_kde_transport function ------------------------------------------


prepare_kde_transport <- function(cleaned_transport_data, transport_methods){
  rail_counts <- cleaned_transport_data |> 
    filter(train == "yes" | subway == "yes") |> 
    group_by(name) |> 
    summarize(
      count = n(),
      geometry = st_point_on_surface(st_union(geometry)),
      .groups = "drop"
    ) |> 
    select(name, count, geometry) |> 
    mutate(
      rail_weight = 2 + log1p(count),
      bus_weight = 0,
      tram_weight = 0,
      ferry_weight = 0,
      unknown_weight = 0
    ) 
  
  other_transport <- cleaned_transport_data |> 
    filter(
      bus == "yes" |
        tram == "yes" |
        ferry == "yes"
    ) |> 
    mutate(
      rail_weight = 0,
      bus_weight = if_else(bus == "yes", 1, 0, missing = 0),
      tram_weight = if_else(tram == "yes", 1, 0, missing = 0),
      ferry_weight = if_else(ferry == "yes", 1, 0, missing = 0),
      unknown_weight = 0
    ) |> 
    select(name, geometry, ends_with("_weight"))
  
  unknown_transport <- cleaned_transport_data|> 
    filter(
      if_all(
        any_of(transport_methods),
        is.na
      )
    ) |> 
    select(name, geometry) |> 
    mutate(
      rail_weight = 0,
      bus_weight = 0,
      tram_weight = 0,
      ferry_weight = 0,
      unknown_weight = 1
    ) 
  
  if (
    !all(
      st_crs(rail_counts) == st_crs(other_transport),
      st_crs(rail_counts) == st_crs(unknown_transport)
    )
  ) {
    warning("CRS mismatch between transport datasets")
  }
  
  transport_kde <- bind_rows(
    rail_counts,
    other_transport,
    unknown_transport
  ) |> 
    mutate(
      total_weight = rail_weight +
        bus_weight +
        tram_weight +
        ferry_weight +
        unknown_weight
    )
  return(transport_kde)
}


chi_kde_transport_table <- prepare_kde_transport(chi_transport_clean, transport_methods)

saveRDS(
  chi_kde_transport_table, file = "data/chi_weighted_transport.rds"
)
