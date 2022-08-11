box::use(tmap[...])
box::use(utils_epidem/utils_epidem)

riskRasterPath = "../../../inputs/inputs_raw/init_conditions/endemic_layer-uganda_2005/inf_raster.tif"

plotDir = "./plots/"
plotPath = file.path(plotDir, "endemic_layer.png")

extent = utils_epidem$get_extent_country_code_vec(c("MOZ", "COD", "KEN"))

# UGA points
ugaPosDf = sf::read_sf("../../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") |>
    dplyr::filter(year==2005 & country_code=="UGA" & cbsd_foliar_bool==TRUE) |>
    dplyr::slice(1)

# --------------------------------

dir.create(plotDir, recursive = TRUE, showWarnings = FALSE)



riskRaster = raster::raster(riskRasterPath)
riskRaster[riskRaster==0] = NA

countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

lakesPoly = sf::st_read("../../data/GLWD-level1/lakes_glwd_1.gpkg")

oceanDf = sf::read_sf("../../data/ne_50m_ocean/ne_50m_ocean.shp")

# ------------------------

p = tm_shape(riskRaster, bbox=extent, raster.downsample=FALSE) +
    tm_raster(
        breaks=c(0, 0.2, 0.4, 0.6, 0.8, 1),
        labels=c("0< to 0.2", "0.2 to 0.4", "0.4 to 0.6", "0.6 to 0.8", "0.8 to 1.0"),
        palette = "Reds",
        title="",
        legend.reverse = TRUE
    ) +
    tm_shape(lakesPoly) +
    tm_fill(col="#A1C5FF", alpha=0.6) +
    tm_borders(lwd=0.05) +
    tm_shape(oceanDf, bbox=extent) +
    tm_fill(col="#A1C5FF", alpha=0.6) +
    tm_shape(countryPolysDfSimple) +
    tm_borders(lwd=0.5) +

    tm_shape(ugaPosDf) +
    tm_symbols(shape=4, col="red", border.lwd=3, size=0.5) +

    tm_compass(position = c("right", "top"), size=5) +
    tm_scale_bar(position = c("right", "bottom"), text.size = 1.2) +
    tm_graticules(lines = FALSE, labels.size=1.2) +
    tm_layout(
        legend.position=c("left", "bottom"),
        legend.frame=TRUE,
        legend.bg.color="grey",
        legend.bg.alpha=0.8,
        legend.text.size = 1.2
    )

# p
tmap_save(p, plotPath)
