box::use(dplyr[`%>%`])

survey_df = sf::read_sf("./outputs/survey_locations/real/NGA-2017.gpkg")

raster_path = "./outputs/2021_03_26_cross_continental/host/host_num_fields.tif"

raster_layer = raster::raster(raster_path)

# Get raster indexes for coords - cellnumbers=TRUE returns the index pos of the corresponding cell
extract_df = raster::extract(raster_layer, survey_df, cellnumbers=TRUE, df=TRUE)

# Extract stats on: raster cell index, number of fields
num_fields_df = unique(extract_df[,c("cells", "host_num_fields")])

# Convert to count of: per raster cell index, how many surveys
cells_df = dplyr::count(extract_df, cells) %>% dplyr::rename(num_surveys_in_cell=n)

# Merge num fields per cell (num_fields_df) with num surveys per cell (cells_df) and work out where more surveys than fields
stats_df = dplyr::left_join(num_fields_df, cells_df, by="cells") %>% 
    dplyr::mutate(problem_bool = num_surveys_in_cell > host_num_fields)

# HACK: Drop cases where more surveys than fields in host cell
stats_df_drop = stats_df[stats_df$problem_bool==FALSE,]

# Save
write.csv(stats_df_drop, "./outputs/survey_scheme.csv", row.names = FALSE)



# hist(stats_df$host_num_fields[stats_df$host_num_fields>0], breaks=100)
# 
# x = raster_layer[]
# 
# hist(x, breaks=20)
# hist(x[x > 0], breaks=20)
# 
# mean(stats_df$host_num_fields)
# 
# plot(raster_layer)
# mapview::mapview(raster_layer)

# First round to 2dp, then ceil




# x = paste0(round(survey_df$latitude, 2), round(survey_df$longitude, 2))
# length(unique(x))
# 608 - 556
# z = survey_df[survey_df$Upload.Source=="Manual Excel Sheet",]

# Check that host num_fields is always greater than num surveys in cell






# x = dplyr::count(extract_df, cells)
# y = extract_df[extract_df$cells==1000760,]
# 
# z = survey_df[extract_df$cells==1000760, ]
# 
# sf::st_geometry(z) = NULL
# 
# write.csv(z, "duplicates.csv", row.names=FALSE)
# x = cbind(
#     survey_df,
#     
# )



# y = raster_layer
# y[] = 0

# for(iRow in seq_len(nrow(x))){
#     print(iRow)    
#     thisRow = x[iRow,]
    
#     y[thisRow$cells] = y[thisRow$cells] + 1
    
# }

# raster::writeRaster(y, "zil.tif")

