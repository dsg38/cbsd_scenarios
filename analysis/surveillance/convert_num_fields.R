raster_dir = "./outputs/2021_03_26_cross_continental/rasters"

output_dir = "./outputs/2021_03_26_cross_continental/rasters_num_fields"

output_dir_agg = "./outputs/2021_03_26_cross_continental/rasters_num_fields_agg"

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(output_dir_agg, recursive = TRUE, showWarnings = FALSE)

raster_paths = list.files(raster_dir, full.names = TRUE)

host_raster = raster::raster("./outputs/2021_03_26_cross_continental/host/host_real/host_num_fields.tif")

i = 1
for(raster_path in raster_paths){

    print(paste0(i, "/", length(raster_paths)))

    out_path = file.path(output_dir, basename(raster_path))
    out_path_agg = file.path(output_dir_agg, basename(raster_path))

    # Convert inf to num fields
    inf_num_fields_raster = host_raster * raster::raster(raster_path)

    # Create 10x aggregated version for better plotting
    raster_agg = raster::aggregate(inf_num_fields_raster, fact=10, fun=sum)

    raster::writeRaster(inf_num_fields_raster, out_path, overwrite=TRUE)
    raster::writeRaster(raster_agg, out_path_agg, overwrite=TRUE)

    i = i + 1

}
