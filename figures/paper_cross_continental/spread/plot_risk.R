args = commandArgs(trailingOnly=TRUE)
box::use(tmap[...])

rasterYear = args[[1]]
# rasterYear = 2050

# Read data / set up crs
hostRaster = raster::raster("../../../inputs/inputs_scenarios/2022_03_15_cross_continental_endemic/inputs/L_0_HOSTDENSITY.txt")

riskRasterPath = file.path("../../../analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/risk_rasters/output/risk/", paste0("risk_", rasterYear,".tif"))

plotDir = "./risk/"
plotPath = file.path(plotDir, gsub(".tif", ".png", basename(riskRasterPath)))

dir.create(plotDir, recursive = TRUE, showWarnings = FALSE)

# --------------------------------
riskRaster = raster::raster(riskRasterPath)
riskRaster[riskRaster == 0] = NA

countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

lakesPoly = sf::st_read("../../data/GLWD-level1/lakes_glwd_1.gpkg")

oceanDf = sf::read_sf("../../data/ne_50m_ocean/ne_50m_ocean.shp")

# Process raster
hostRaster[hostRaster == 0] = NA

# Convert to num fields
hostRaster = hostRaster * 1000

extent = c(
    xmin=-17.54167,
    ymin=-26.86667,
    xmax=45,
    ymax=15
)


# ---------------------------------
# Host
p = tm_shape(hostRaster, bbox=extent, raster.downsample=FALSE) +
    tm_raster(
        breaks=c(0, 1, 5, 10, 50, 100, 1000),
        labels=c("< 1", "1 to 5", "5 to 10", "10 to 50", "50 to 100", "100 to 1000"),
        colorNA = "white",
        textNA = "No production",
        palette = "Greens",
        title="",
        legend.reverse = TRUE
    ) +
    tm_shape(riskRaster, raster.downsample=FALSE) +
    tm_raster(
        breaks=c(0, 0.2, 0.4, 0.6, 0.8, 1),
        labels=c("0< to 0.2", "0.2 to 0.4", "0.4 to 0.6", "0.6 to 0.8", "0.8 to 1.0"),
        # labels=c("0 < x <= 0.2", "0.2 < x <= 0.4", "0.4 < x <= 0.6", "0.6 < x <= 0.8", "0.8 < x <= 1.0"),
        palette = "Reds",
        title="",
        legend.reverse = TRUE
    ) +
    tm_shape(lakesPoly) +
    tm_fill(col="#A1C5FF") +
    tm_shape(oceanDf, bbox=extent) +
    tm_fill(col="#A1C5FF") +
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
        legend.text.size = 1.2,
        main.title=rasterYear,
        main.title.position = "center"
    )

# p
tmap_save(p, plotPath)


