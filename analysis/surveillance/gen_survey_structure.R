box::use(dplyr[`%>%`])

survey_df = sf::read_sf("./outputs/2021_03_26_cross_continental/survey_locations/host_real/survey_real/NGA-2017.gpkg")

raster_path = "./outputs/2021_03_26_cross_continental/host/host_real/host_num_fields.tif"

raster_layer = raster::raster(raster_path)

# Get raster indexes for coords - cellnumbers=TRUE returns the index pos of the corresponding cell
extract_df = raster::extract(raster_layer, survey_df, cellnumbers=TRUE, df=TRUE) %>%
    dplyr::rename(raster_index=cells)

# Gen mapping between raster index and coords
extract_df_merged = dplyr::bind_cols(
        extract_df,
        latitude=survey_df$latitude,
        longitude=survey_df$longitude)

# Extract stats on: raster cell index, number of fields
num_fields_df = unique(extract_df_merged[,c("raster_index", "host_num_fields", "latitude", "longitude")])

# Convert to count of: per raster cell index, how many surveys
cells_df = dplyr::count(extract_df_merged, raster_index) %>% dplyr::rename(num_surveys_in_cell=n)

# Merge num fields per cell (num_fields_df) with num surveys per cell (cells_df) and work out where more surveys than fields
stats_df = dplyr::left_join(num_fields_df, cells_df, by="raster_index") %>% 
    dplyr::mutate(problem_bool = num_surveys_in_cell > host_num_fields)

# HACK: Drop cases where more surveys than fields in host cell
stats_df_drop = stats_df[stats_df$problem_bool==FALSE,]

# Save
write.csv(stats_df_drop, "./outputs/2021_03_26_cross_continental/survey_locations/host_real/survey_real/survey_scheme.csv", row.names = FALSE)
