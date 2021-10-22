box::use(utils_epidem/utils_epidem)

polys_0_df = sf::read_sf("../inputs_raw/polygons/polys_0_host_default.gpkg")

targetPolys = c("mask_uga_hole", "mask_uga_kam")

polysFittingDf = polys_0_df[polys_0_df$POLY_ID %in% targetPolys,]

outPath = "../inputs_raw/polygons/polys_fitting.gpkg"

utils_epidem$sf_write_sf_ro(polysFittingDf, outPath)

