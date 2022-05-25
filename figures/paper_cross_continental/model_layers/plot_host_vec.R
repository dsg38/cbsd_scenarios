box::use(tmap[...])

# Read data / set up crs
vectorRaster = raster::raster("../../../inputs/inputs_raw/vector/cassava_data-2022_02_09/vector.tif", crs="EPSG:4326")
hostRaster = raster::raster("../../../inputs/inputs_raw/host_landscape/CassavaMap-cassava_data-2022_02_09/host.tif")

# --------------------------------

countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)

lakesPoly = sf::st_read("../../data/GLWD-level1/lakes_glwd_1.gpkg")

oceanDf = sf::read_sf("../../data/ne_50m_ocean/ne_50m_ocean.shp")

# Process raster
vectorRaster[vectorRaster == 0] = NA
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

# Vector
p = tm_shape(vectorRaster, bbox=extent, raster.downsample=FALSE) +
    tm_raster(
        style = "cont",
        breaks=seq(0,1, 0.1),
        legend.reverse = TRUE,
        title="",
        palette = tmaptools::get_brewer_pal("YlOrBr", n = 7)[1:6],
        alpha=0.7
    ) +
    tm_shape(lakesPoly, bbox=extent) +
    tm_fill(col="#A1C5FF") +
    tm_shape(oceanDf, bbox=extent) +
    tm_fill(col="#A1C5FF") +
    tm_shape(countryPolysDfSimple, bbox=extent) +
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
tmap_save(p, "./plots/layer_vector.png")

# ---------------------------------
#  # Host
q = tm_shape(hostRaster, bbox=extent, raster.downsample=FALSE) +
    tm_raster(
        breaks=c(0, 1, 5, 10, 50, 100, 1000),
        labels=c("< 1", "1 to 5", "5 to 10", "10 to 50", "50 to 100", "100 to 1000"),
        colorNA = "white",
        textNA = "No production",
        palette = "Greens",
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
        legend.text.size = 1.2
    )

# q
tmap_save(q, "./plots/layer_host.png")
