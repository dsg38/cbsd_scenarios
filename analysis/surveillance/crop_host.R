box::use(utils_epidem/utils_epidem)

host_raster_path = "../../inputs/inputs_raw/host_landscape/default/host.tif"

country_code_vec = c("NGA", "CMR")

extent_bbox = utils_epidem$get_extent_country_code_vec(country_code_vec)

host_cropped = utils_epidem$crop_raster_extent(
    raster_path=host_raster_path,
    extent_bbox=extent_bbox
)

host_num_fields = host_cropped * 1000

raster::writeRaster(host_num_fields, "./outputs/2021_03_26_cross_continental/host/host_real/host_num_fields.tif")
