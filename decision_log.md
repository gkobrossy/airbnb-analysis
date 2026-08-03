# 2026-08-03

## Determining weights for public transport using `chi_transport_clean` and `chi_transport_data$osm_points`

### Issue
`chi_transport_clean` did not retain the transport mode attributes needed to assign weights (e.g., bus, train, ferry). However, `chi_transport_data$osm_points` contained mode-specific columns:

- `bus`
- `subway`
- `train`
- `tram`
- `ferry`
- `railway`

These attributes were needed to distinguish between different types of transportation features.
These attributes were saved as the character vector `transport_methods` for the analysis.

### Investigation
The transport mode columns from `chi_transport_data$osm_points` were examined to determine whether any features lacked all available `transport_method` information.

Rows were filtered where all of the following columns were `NA`:

- `bus`
- `subway`
- `train`
- `tram`
- `ferry`
- `railway`

Only 4 features lacked all mode information:

- 0 from `osm_points`
- 3 from `osm_polygons`
- 1 from `osm_multipolygons`

These 4 features were classified as `public_transport = station`, not `stop_position`

Manual inspection showed these features were real transportation-related features (e.g., stations/water taxi), but OSM did not provide sufficient metadata to classify their transportation mode.

### Decision
Retain these features as transportation observations in the `clean_osm_data()` function, and classify them as `unknown` rather than removing them.

Unknown transportation features will receive a baseline weight because they represent valid infrastructure but lack information needed for mode-specific weighting.

### Rationale
Removing these features could introduce bias by excluding transportation infrastructure based only on incomplete OSM tagging. Since the number of affected observations was very small, retaining them preserves information while minimizing their influence.

### Alternative approaches considered
Remove data where `public_transport = station`: Rejected because this would also remove meaningful, real stations. 

## Computing weights for public transport 

### Issue

The different methods of public transportation should have different weights in the KDE based on their accessibility.

- `bus`
- `subway`
- `train`
- `tram`
- `ferry`
- `railway`


### Investigation
The rows in `chi_transport_clean` were examined to determine weight. 
Different OSM objects representing the same station had different `osm_id` values, 
so `osm_id` could not be used for aggregation. Instead, stations were aggregated by `name`. 
Bus stops were also found to generally have 2 points, representing directional stops (Northbound, Southbound)

### Decision
`bus`, `tram`, and `ferry` stops were assigned to have weight = 1 because each represents a distinct access to transit.

`train` and `subway` stations were aggregated using `name` and assigned $\text{weight} = 2 + \text{log1p}(n)$, where n is the number of rows/stops for each station.

### Rationale

`train` and `subway` stations were aggregated because multiple OSM features frequently represented components of the same physical station. 
`train` and `subway` contribute more to KDE because they are high-capacity, fast methods of transit.
The log transformation was applied to reduce sensitivity to highly detailed mappings of certain stations, while still allowing larger transport hubs to contribute more strongly to the KDE.

### Alternative approaches considered
Different weights for `train` and `subway` stations: Rejected because using 
$\text{weight} = \text{log1p}(n)$ or 
$\text{weight} = 1 + \text{log1p}(n)$
would assign train stations with only 2 stops a smaller weight than 1 bus station, 
since a bus stop generally includes 2 stops, each with weight = 1.


# Late July (Culture preprocessing)

## Culture Data Preprocessing: Removing `tourism = viewpoint` from culture features

### Issue
OpenStreetMap culture data contained a large number of features tagged as `tourism = viewpoint`. These features were evaluated to determine whether they represented independent cultural destinations appropriate for inclusion in the future KDE.

### Investigation
Unnamed tourism points were inspected to determine their meaning. Among tourism features with `name = NA`, the majority were classified as viewpoints rather than independent attractions.

Manual inspection showed that many viewpoints were:
- internal observation locations within larger attractions (e.g., zoos or museums),
- scenic overlooks within parks,
- bridge or infrastructure viewpoints.

These features did not consistently represent destinations that would attract urban activity in the same way as museums, galleries, theaters, or other cultural venues.

### Decision
Remove `tourism = viewpoint` features from the culture dataset before calculating spatial density measures.

### Rationale
Including viewpoints would artificially increase cultural density in areas containing many internal observation points or scenic features, causing the KDE to reflect OSM mapping practices rather than the concentration of cultural destinations.

Removing viewpoints better aligns the dataset with the goal of measuring urban activity generated by distinct cultural destinations.

### Alternative approaches considered
- Retain all viewpoints: rejected because many viewpoints were not independent destinations.
- Remove only unnamed viewpoints: rejected because some named viewpoints may still represent a different type of attraction than the desired cultural features.
- Keep viewpoints as a separate category: possible future extension, but not included in the current urban activity index.




