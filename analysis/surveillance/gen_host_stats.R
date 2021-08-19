host_raster_path = "./outputs/2021_03_26_cross_continental/host/host_real/host_num_fields.tif"

host_raster = raster::raster(host_raster_path)

num_fields = raster::cellStats(host_raster, stat='sum', asSample=FALSE)

df = data.frame(
    raster_name=basename(host_raster_path),
    num_fields=num_fields
)

write.csv(df, "./outputs/2021_03_26_cross_continental/host/host_real/stats_host_num_fields.csv", row.names=FALSE)

