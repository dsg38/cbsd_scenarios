box::use(dplyr[`%>%`])
box::use(utils_epidem/utils_epidem)
box::use(tmap[...])

raster_path = "./outputs/2021_03_26_cross_continental/host/host_real/host_num_fields.tif"
out_path = "./outputs//2021_03_26_cross_continental/plots/host/host.png"

# --------------------------

propRaster = raster::raster(raster_path)

propRaster[propRaster==0] = NA

africa_polys_df = utils_epidem$getAfricaPolys()
extent_bbox = sf::st_bbox(africa_polys_df[africa_polys_df$GID_0=="NGA",])

p = tm_shape(propRaster, bbox=extent_bbox) + 
    tm_raster(
        title = "Number of cassava fields",
        palette="Greens"
    ) + 
    tm_shape(africa_polys_df) +
    tm_borders() + 
    tm_layout(legend.outside = TRUE, legend.outside.size=0.15)

tmap_save(p, out_path)
