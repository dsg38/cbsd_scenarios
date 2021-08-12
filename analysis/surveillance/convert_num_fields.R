raster_dir = "./outputs/2021_03_26_cross_continental/rasters"

output_dir = "./outputs/2021_03_26_cross_continental/rasters_num_fields"

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

raster_paths = list.files(raster_dir, full.names = TRUE)

host_raster = raster::raster("./outputs/2021_03_26_cross_continental/host/host_num_fields.tif")

i = 1
for(raster_path in raster_paths){

    print(paste0(i, "/", length(raster_paths)))

    out_path = file.path(output_dir, basename(raster_path))

    # Convert inf to num fields
    inf_num_fields_raster = host_raster * raster::raster(raster_path)

    raster::writeRaster(inf_num_fields_raster, out_path, overwrite=TRUE)

    i = i + 1

}
