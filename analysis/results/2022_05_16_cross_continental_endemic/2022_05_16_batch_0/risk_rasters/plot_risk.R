box::use(tmap[...])
box::use(utils_epidem/utils_epidem)

plotDir = "./output/risk/plots/"

extent = utils_epidem$get_extent_country_code_vec(c("COD", "SEN", "AGO", "UGA"))

# --------------------------------

dir.create(plotDir, recursive = TRUE, showWarnings = FALSE)

riskRasterPaths = list.files("./output/risk/rasters", "risk_", full.names = TRUE)

for(riskRasterPath in riskRasterPaths){

    plotPath = file.path(plotDir, gsub(".tif", ".png", basename(riskRasterPath)))

    print(plotPath)

    riskRaster = raster::raster(riskRasterPath)
    riskRaster[riskRaster < 0.01] = NA

    countryPolysDf = sf::read_sf("../../../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
    countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

    lakesPoly = sf::st_read("../../../../../figures/data/GLWD-level1/lakes_glwd_1.gpkg")

    oceanDf = sf::read_sf("../../../../../figures/data/ne_50m_ocean/ne_50m_ocean.shp")

    # extent = c(
    #     xmin=-17.54167,
    #     ymin=-26.86667,
    #     xmax=45,
    #     ymax=15
    # )

    # Blue = #A1C5FF
    # Grey = #CFCED2
    # Grey = #A1C5FF - alpha = 

    # ---------------------------------
    p = tm_shape(riskRaster, bbox=extent, raster.downsample=FALSE) +
        tm_raster(
            breaks=c(0, 0.2, 0.4, 0.6, 0.8, 1),
            labels=c("0.01< to 0.2", "0.2 to 0.4", "0.4 to 0.6", "0.6 to 0.8", "0.8 to 1.0"),
            # labels=c("0 < x <= 0.2", "0.2 < x <= 0.4", "0.4 < x <= 0.6", "0.6 < x <= 0.8", "0.8 < x <= 1.0"),
            palette = "Reds",
            title="",
            legend.reverse = TRUE
        ) +
        tm_shape(lakesPoly) +
        tm_fill(col="#CFCED2") +
        tm_shape(oceanDf, bbox=extent) +
        tm_fill(col="#CFCED2") +
        tm_shape(countryPolysDfSimple) +
        tm_borders(lwd=0.5) +
        tm_compass(position = c("right", "top"), size=5) +
        tm_scale_bar(position = c("right", "bottom"), text.size = 1.2) +
        tm_graticules(lines = FALSE, labels.size=1.2) +
        tm_layout(
            legend.position=c("left", "bottom"),
            legend.frame=TRUE,
            legend.bg.color="grey",
            legend.bg.alpha=0.8,
            legend.text.size = 1.2
            # main.title="20XX",
            # main.title.position = "center"
        )

    # p
    tmap_save(p, plotPath)

}
