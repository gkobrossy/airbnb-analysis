# Airbnb Listing Analysis

## Overview

This project explores Airbnb listing data using R and Quarto. The goal is to investigate how patterns in listing characteristics and location predict price.
This project is still ongoing, and this document will be continuously updated.

## Data

### Airbnb Data
The data used in this project is from the Kaggle dataset:

[Airbnb Listings in Major US Cities - Deloitte ML](https://www.kaggle.com/datasets/rudymizrahi/airbnb-listings-in-major-us-cities-deloitte-ml)

This project uses the `train.csv` file from the dataset. The original dataset was created for a machine learning competition, but this analysis uses the data for exploratory data analysis, regression modeling, and spatial analysis.
The analysis uses a random sample from `train.csv`.

The raw dataset is not included in this repository.

### Map Data
The location data, such as nearby entertainment, parks, public transit is obtained from the osmdata package.

## Methods

This analysis uses:

- Data cleaning
- Exploratory data analysis
- Data visualization
- Statistical modeling
- Spatial feature engineering using OpenStreetMap data
- Kernel Density Estimates (KDE)

## Spatial Feature Engineering

OpenStreetMap (OSM) data were used to create spatial measures of nearby urban activity and transportation accessibility. 
Since OSM represents real-world features using different geometry types (points, polygons, multipolygons, and lines), 
features were processed individually before kernel density estimation (KDE).

All spatial operations were performed using a projected coordinate reference system to allow distance-based calculations in meters.

| City | EPSG |
|---|---|
|Chicago|26916|
|Boston| TBD|
|LA| TBD|
|SF| TBD|
|DC| TBD|

### OSM Feature Processing

The OSM data was processed before running the KDE. 

| Feature Category | OSM Tags | OSM Features| Processing | Weighting |
|---|---|---|---|---|
| Entertainment | `amenity` |bar,
                         pub,
                         nightclub,
                         theatre,
                         cinema,
                         arts_centre
                         )| Points, polygons, multipolygons, and lines converted to representative points | Equal weight |
| Culture/Tourism | `tourism` | TBD |  Points, polygons, multipolygons, and lines converted to representative points. Viewpoints removed | Equal weight |
| Public Transportation | `public_transport` | TBD|  Rail stations aggregated by station name. Bus, tram, and ferry stops retained as individual access points. | Mode-specific weights |
| Parks | TBD | TBD | TBD | TBD| 

### OSM Data Processing Decisions

#### Culture/Tourism Processing Decisions

Viewpoints were excluded because they do not consistently represent independent urban destinations relevant to neighborhood activity. Many viewpoints corresponded to internal features of larger attractions (such as museums, zoos, and parks) or isolated scenic locations such as bridge overlooks. Including these features would artificially increase local activity density without representing additional destinations.

Parks were retained because major urban parks represent meaningful activity spaces. Named parks were prioritized to reduce the inclusion of small green spaces that may not represent destinations.

#### Public Transportation Weighting and Processing Decisions

| Transportation Type | Processing | Weight |
|---|---|---|
| Bus | Individual stops retained as separate access points | 1 |
| Tram | Individual stops retained as separate access points | 1 |
| Ferry | Individual stops retained as separate access points | 1 |
| Train/Subway | Aggregated by station name to combine duplicate OSM representations | $\text{Weight} = 2 + \text{log1p}(n)$ |
| Unknown transit type | Retained when a public transport feature lacked a specific mode classification | 1 |

The number of OSM features associated with rail stations was used as a secondary measure of station complexity. A logarithmic transformation was applied to reduce the influence of highly detailed OSM mappings while allowing larger transportation hubs to contribute more strongly.

### Limitations
OpenStreetMap is a community-maintained dataset, 
and the same real-world feature may be represented differently across categories. 
For example, large transit stations may consist of multiple platforms and stop positions, 
while parks are stored as polygons rather than points. 
Preprocessing was therefore tailored to each feature type to ensure that the resulting spatial 
metrics better reflected the intended concept of urban activity.

## Tools

- R
- Quarto
- tidyverse
- sf
- osmdata
- spatstat

## Reproducibility

The analysis can be reproduced by obtaining the dataset and running:

`airbnb_analysis.qmd`
