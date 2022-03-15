tempRasterPath = "./outputs/control_raster_TEMP.tif"

posValTemp = 12345
negValTemp = 54321

# -----------------------

controlDistrictsDf = sf::read_sf("./inputs/uga_admbnda_ubos_20200824.gdb", layer="uga_admbnda_adm2_ubos_20200824") |>
    dplyr::rename(geom=Shape)|> 
    dplyr::filter(admin2Name_en%in%c("Luwero", "Mukono", "Nakasongola", "Wakiso")) # Filter out the 4 target districts

# Merge the districts into a single poly
geom = controlDistrictsDf |>
    sf::st_union()

# Convert poly to sf df
controlMergedDf = sf::st_sf(
    poly_name="uga_merged_districts_control",
    geom=geom
)

# Read in template raster
hostRaster = raster::raster("../../host_landscape/CassavaMap/host.tif")
raster::crs(hostRaster) = "EPSG:4326"

# Create bool raster using the poly 
polyRaster = raster::rasterize(x=controlMergedDf, y=hostRaster, field=posValTemp, background=negValTemp)

# Save raster
dir.create("./outputs", showWarnings = FALSE)
raster::writeRaster(polyRaster, tempRasterPath, overwrite=TRUE)
