# Airbnb Listing Analysis

## Overview

This project explores Airbnb listing data using R and Quarto. The goal is to investigate how patterns in listing characteristics and location predict price.
This project is still ongoing, and this document will be continuously updated.

## Data

### Airbnb Data
The data used in this project come from the Kaggle dataset:

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

## Tools

- R
- Quarto
- tidyverse
- sf
- osmdata

## Reproducibility

The analysis can be reproduced by obtaining the dataset and running:

`airbnb_analysis.qmd`
