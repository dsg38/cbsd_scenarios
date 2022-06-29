library(tmap)
library(tictoc)
args = commandArgs(trailingOnly=TRUE)

tic()

rankIndex = as.numeric(args[[1]])

outPath = file.path("plots", paste0("rank_", sprintf("%06d", rankIndex), ".tif"))

dir.create(dirname(outPath), recursive = TRUE, showWarnings = FALSE)
# -------------------------

rankDf = read.csv("./output/rankDf.csv")

thisSimKey = rankDf[rankDf$rank==rankIndex, "simKey"]

thisJob = dplyr::nth(stringr::str_split(thisSimKey, "-")[[1]], -2)

jobDir = file.path("../../../../../simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0", thisJob,"output/runfolder0")

rasterPaths = rev(file.path(jobDir, paste0("O_0_L_0_INFECTIOUS_", c(2023, 2030, 2040, 2050), ".000000.tif")))
colsVec = c("Reds", "Oranges", "Greens", "Blues")

# Setup base plot
countryPolysDf = sf::read_sf("../../../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

hostRaster = raster::raster("../../../../../inputs/inputs_scenarios/2022_03_15_cross_continental_endemic/inputs/L_0_HOSTDENSITY.txt")

extent = c(
    xmin=-17.54167,
    ymin=-26.86667,
    xmax=45,
    ymax=15
)

p = tm_shape(countryPolysDfSimple, bbox=extent) +
    tm_borders(lwd=0.5) +
    tm_add_legend('fill', 
        col = c("Blue", "Green", "Orange", "Red"),
        border.col = "grey40",
        labels = c(2023, 2030, 2040, 2050),
    	title=""
    )

# p

# Loop adding layers
i = 1
for(thisRasterPath in rasterPaths){
    
    print(i)

    riskRaster = raster::raster(thisRasterPath)
    riskRaster[riskRaster==0] = NA
    riskRaster = riskRaster * hostRaster * 1000

    p = p +
        tm_shape(riskRaster, bbox=extent, raster.downsample=FALSE) + 
        tm_raster(
            breaks=c(0, 1, 5, 10, 50, 100, 1000),
            palette = colsVec[[i]],
            legend.show = FALSE
        ) +
        tm_compass(position = c("right", "top"), size=5) +
        tm_graticules(lines = FALSE, labels.size=1.2) +
        tm_layout(
            legend.position=c("left", "bottom"),
            legend.frame=TRUE,
            legend.bg.color="grey",
            legend.bg.alpha=0.8,
            legend.text.size = 1.2,
            main.title.position = "center"
        )

    i = i + 1
}


# p
tmap_save(p, outPath)

toc()
