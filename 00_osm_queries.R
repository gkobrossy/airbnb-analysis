# Airbnb Listing Analysis
# 00_osm_queries.R
#
# Purpose:
# Query OSM to get the amenities in each city. This only needs to be run once, and the osmdata queries may timeout
# due to the consecutive queries. It may be easier to run each query seperately or run 02_clean_and_prepare.R with the
# existing files uploaded. 
#
# Data:
# osmdata that is used for 02_clean_and_prepare.R. It is not necessary to run this script, as the resulting .rds 
# files are in the repository. 
#
# Author: George Kobrossy
# Date: 2026-10-25
source("config.R")



# Code to get data from OSM and save RDS files ----------------------------


entertainment_query <- opq(bbox = chi_bbox_buffered) |>
  add_osm_feature(
    key = "amenity",
    value = c(
       "bar",
       "pub",
       "nightclub",
       "theatre",
       "cinema",
       "arts_centre"
       )
    )

entertainment_data <- osmdata_sf(entertainment_query)

culture_query <- opq(bbox = chi_bbox_buffered) |>
   add_osm_feature(
     key = "tourism",
     value = c(
       "museum",
       "gallery",
       "attraction",
       "viewpoint",
       "hotel"
     )
   )

culture_data <- osmdata_sf(culture_query)

transport_query <- opq(bbox = chi_bbox_buffered) |>
   add_osm_feature(
     key = "public_transport",
     value = c("station", "stop_position")
   )

transport_data <- osmdata_sf(transport_query)

park_query <- opq(bbox = chi_bbox_buffered) |>
    add_osm_feature(        key = "leisure",
        value = c("park")
     )
park_data <- osmdata_sf(park_query)

saveRDS(entertainment_data, file = "data/chi_entertainment.rds")
saveRDS(culture_data, file = "data/chi_culture.rds")
saveRDS(transport_data, file = "data/chi_transport.rds")
saveRDS(park_data, "data_private/chi_parks.rds")
