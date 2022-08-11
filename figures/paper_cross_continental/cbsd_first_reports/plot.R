box::use(tmap[...])
box::use(utils_epidem/utils_epidem)

countryPolysDf = sf::read_sf("../../../inputs/process_polys/gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

polyDf = sf::read_sf("./inputs/target_polys.gpkg")

targetYearDf = read.csv("../../../analysis/results/2022_03_15_cross_continental_endemic/2022_03_20_batch_0/config/inf_target_years.csv")

oceanDf = sf::read_sf("../../data/ne_50m_ocean/ne_50m_ocean.shp")

# ----------------------------------------------

polyTargetDf = dplyr::left_join(polyDf, targetYearDf, by="POLY_ID") |>
    dplyr::arrange(report_year)

bboxExtent = utils_epidem$getCountryVecExtentVec(
    c("CAF", "ZMB", "KEN")
)

oceanDfCrop = sf::st_crop(oceanDf, bboxExtent)

countryPolysDfSimple = sf::st_simplify(countryPolysDf, dTolerance = 1000)
# ----------------------------------------------

p = tm_shape(oceanDf, bbox=bboxExtent) +
    tm_fill(col="#A1C5FF", alpha=0.6) +
    tm_shape(countryPolysDfSimple) +
    tm_polygons(alpha=0.5, lwd=0.5) +
    tm_shape(polyTargetDf) +
    tm_polygons(col="display_name", title="") +
    tm_text("report_year", 
            xmod=c(1.2, -2.5, 2.5, -2.3, -2.5, 2.2, -2.3), 
            ymod=c(1.6, 0, 0, 0, 0, -0.9, 0),
            size=1.3
    ) +
    tm_layout(
        legend.position = c("left", "top"),
        legend.frame=TRUE,
        legend.bg.color="grey",
        legend.bg.alpha=0.8,
        legend.text.size = 1
    ) +
    tm_compass(position = c("right", "top"), size=5) +
    tm_scale_bar(position = c("left", "bottom"), text.size = 1.2) +
    tm_graticules(lines = FALSE, labels.size=1.5)

# p

tmap::tmap_save(p, "./plots/map_cbsd_first_reports.png")

