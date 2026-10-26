# Airbnb Listing Analysis
# 01_load_data.R
#
# Purpose:
# Load packages and raw datasets used throughout the analysis.
#
# Data:
# Airbnb Listings in Major US Cities - Deloitte ML
#
# Author: George Kobrossy
# Date: 2026-09-19

library(tidyverse)
library(tigris)
library(osmdata)
library(sf)

set.seed(42)


# Loading the US Coastline Data with tigris and sf ------------------------

state_boundaries <- states(year = 2025)

us_coastline <- state_boundaries |>
  filter(REGION != 9 & !(STUSPS %in% c("AK", "HI"))) |> 
  st_union() |>
  st_cast("MULTILINESTRING")

saveRDS(
  us_coastline, 
  file = "data/us_coastline.rds"
)

saveRDS(
  state_boundaries,
  file = "data/state_boundaries.rds"
  
)


# Loading in the AirBNB Data and taking a random sample -------------------


bnb_data <- read_csv("data/train.csv") |>
   select(-thumbnail_url)

bnb_sample <- bnb_data |>
   slice_sample(n = 10000)

saveRDS(
  bnb_data, 
  file = "data/bnb_data.rds"
)

saveRDS(
  bnb_sample, 
  file = "data/bnb_sample.rds"
)
  



