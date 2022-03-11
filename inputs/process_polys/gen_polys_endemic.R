box::use(./utils)

hostRasterPath = "../inputs_raw/host_landscape/CassavaMap/host.tif"

cassavaCountriesDf = sf::read_sf("../inputs_raw/polygons/polys_cassava_host_CassavaMap.gpkg")

endemicPolysDf = sf::read_sf("../inputs_raw/init_conditions/endemic_seed/endemic_poly.gpkg") |>
    dplyr::mutate(POLY_ID=paste0("endemic_", SOV_A3)) |>
    dplyr::select(POLY_ID, geom)

endemicDfStats = utils$appendHostStats(
    polyDfIn=endemicPolysDf,
    hostRasterPath=hostRasterPath
)

polyDfMerged = dplyr::bind_rows(cassavaCountriesDf, endemicDfStats)

sf::write_sf(polyDfMerged, "../inputs_raw/polygons/polys_cassava_endemic_host_CassavaMap.gpkg")
