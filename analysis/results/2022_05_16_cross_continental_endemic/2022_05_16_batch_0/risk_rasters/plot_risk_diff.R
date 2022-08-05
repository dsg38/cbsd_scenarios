box::use(tmap[...])
box::use(utils_epidem/utils_epidem)

diffRasterPaths = list.files("./output/diff/rasters", "diff_", full.names = TRUE)

extent = utils_epidem$get_extent_country_code_vec(c("COD", "SEN", "AGO", "UGA"))

plotDir = "./output/diff/plots/"
dir.create(plotDir, recursive = TRUE, showWarnings = FALSE)

for(diffRasterPath in diffRasterPaths){

    print(diffRasterPath)
    
    diffRaster = raster::raster(diffRasterPath)

    plotPath = file.path(plotDir, gsub(".tif", ".png", basename(diffRasterPath)))

    countryPolysDf = sf::read_sf("../../../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
    countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

    lakesPoly = sf::st_read("../../../../../figures/data/GLWD-level1/lakes_glwd_1.gpkg")

    oceanDf = sf::read_sf("../../../../../figures/data/ne_50m_ocean/ne_50m_ocean.shp")
    # ---------------------------------
    # Host
    p = tm_shape(diffRaster, bbox=extent, raster.downsample=FALSE) +
        tm_raster(
            breaks=seq(0, 0.7, 0.1),
            labels=c("0< to 0.1", "0.1 to 0.2", "0.2 to 0.3", "0.3 to 0.4", "0.4 to 0.5", "0.5 to 0.6", "0.6 to 0.7"),
            # palette = "Reds",
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
        )

    # p
    tmap_save(p, plotPath)
    
}

