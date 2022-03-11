box::use(utils_epidem/utils_epidem)

polys_0_df = sf::read_sf("../inputs_raw/polygons/polys_0_host_CassavaMap.gpkg")

targetPolys = c("mask_uga_hole", "mask_uga_kam")

polysFittingDf = polys_0_df[polys_0_df$POLY_ID %in% targetPolys,]

outPath = "../inputs_raw/polygons/polys_fitting_host_CassavaMap.gpkg"

utils_epidem$write_sf(polysFittingDf, outPath)

