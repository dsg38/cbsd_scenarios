library(tmap)

plotPath = file.path("./plots/2022_08_26_detectionProp_085/simple/simple_gridRes_20.png")
dir.create(dirname(plotPath), showWarnings = FALSE, recursive = TRUE)

# Read in simple df
simpleDf = sf::read_sf("./results/2022_08_26_detectionProp_085/simple_gridRes_20.gpkg") |>
    dplyr::filter(prop > 0)

# Read in country polys
statePolysDf = sf::read_sf("../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level1_africa.gpkg")

countryPolysDf = sf::read_sf("../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

# Extent poly
extentDf = countryPolysDf |>
    dplyr::filter(GID_0 == "NGA")


p = tm_shape(statePolysDf, bbox = extentDf) + 
    tm_borders(lwd=0.2) +
    tm_shape(countryPolysDf, bbox = extentDf) + 
    tm_borders(lwd=0.8) +
    tm_shape(simpleDf) +
    tm_polygons(col="prop", alpha=0.8, title="") +
    tm_layout(
        legend.position=c("left", "bottom"),
        legend.frame=TRUE,
        legend.bg.color="grey",
        legend.bg.alpha=0.8,
        legend.text.size = 1.2
    )

# p
tmap_save(tm=p, filename = plotPath)
