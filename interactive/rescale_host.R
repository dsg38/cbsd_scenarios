rescaleHost = function(
    hostRasterPath,
    outPath
){

    r = raster::raster(hostRasterPath)

    # Add crs
    raster::crs(r) = "EPSG:4326"

    # Convert to num fields
    r = r * 1000

    # Aggregate x10
    r = raster::aggregate(r, fact=10, fun=sum)

    # Save
    raster::writeRaster(r, outPath)


}

# rescaleHost(
#     hostRasterPath = "../inputs/inputs_scenarios/2021_03_17_uganda/inputs/L_0_HOSTDENSITY.txt",
#     outPath = "data/host_num_fields_uga.tif"
# )

rescaleHost(
    hostRasterPath = "./data/raw/host.tif",
    outPath = "data/host_num_fields.tif"
)
