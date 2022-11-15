box::use(../../utils/utils_surveillance)
tmap::tmap_options(check.and.fix = TRUE)

plotSimpleGrid = function(
    simpleDfPath,
    extentBbox,
    optimalDfRow,
    breaks,
    legendPos,
    plotPath
){  

    box::use(tmap[...])

    dir.create(dirname(plotPath), showWarnings = FALSE, recursive = TRUE)

    # Read in simple df
    simpleDf = sf::read_sf(simpleDfPath) |>
        dplyr::filter(prop > 0)

    # Read in country polys
    statePolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level1_africa.gpkg")

    countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

    # Def title
    plotTitle = paste0("numSurveys: ", optimalDfRow$numSurveys, " | detectionProb: ", optimalDfRow$detectionProb, " | objFuncVal: ", round(optimalDfRow$objective_func_val, 2))

    # Check that plotting range covers all vals
    stopifnot(all(simpleDf$prop<=max(breaks)))

    p = tm_shape(statePolysDf, bbox = extentBbox) + 
        tm_borders(lwd=0.2) +
        tm_shape(countryPolysDf, bbox = extentBbox) + 
        tm_borders(lwd=0.8) +
        tm_shape(simpleDf) +
        tm_polygons(
            col="prop", 
            alpha=0.8, 
            title="",
            breaks=breaks,
            style="cont"
        ) +
        tm_layout(
            legend.position=legendPos,
            legend.frame=TRUE,
            legend.bg.color="grey",
            legend.bg.alpha=0.8,
            legend.text.size = 1.2,
            asp = 1,
            title = plotTitle
        )

    # p
    tmap_save(tm=p, filename = plotPath)

}

optimalDfPath = "./data/optimalDf.csv"

breaks = seq(0, 0.3, 0.05)

# CLUSTERS CHUNK

simpleDfDir = "./data/simple_clusters"

x = list.files("./data/simple_clusters/", "*.gpkg", full.names = TRUE)

stackdDfList = list()
for(thisPath in x){
    stackdDfList[[thisPath]] = sf::read_sf(thisPath)    
}

y = dplyr::bind_rows(stackdDfList)

extentBbox = sf::st_bbox(y)

legendPos = c("right", "bottom")

# --------------------------------

simpleDfPaths = list.files(simpleDfDir, full.names = TRUE)

optimalDf = read.csv(optimalDfPath)

for(simpleDfPath in simpleDfPaths){

    gridName = tools::file_path_sans_ext(basename(simpleDfPath))

    sweepIndex = dplyr::last(stringr::str_split(gridName, "_")[[1]])

    plotPath = file.path("./plots", basename(simpleDfDir), paste0(gridName, ".png"))

    optimalDfRow = optimalDf[optimalDf$sweep_i == sweepIndex,]
    
    print(plotPath)
    
    utils_surveillance$plotSimpleGrid(
        simpleDfPath = simpleDfPath,
        extentBbox = extentBbox,
        optimalDfRow = optimalDfRow,
        breaks = breaks,
        legendPos = legendPos,
        plotPath = plotPath
    )

}
