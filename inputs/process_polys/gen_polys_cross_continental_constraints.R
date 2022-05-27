box::use(./utils)

countriesDf = sf::read_sf("./gadm36_levels_gpkg/gadm36_level0_africa.gpkg")
regionsDf = sf::read_sf("./gadm36_levels_gpkg/gadm36_level1_africa.gpkg")
subRegionsDf = sf::read_sf("./gadm36_levels_gpkg/gadm36_level2_africa.gpkg")

hostCountriesCodesDf = read.csv("../inputs_raw/host_landscape/CassavaMap/raw/host_country_codes.csv")

# Zambian small regions of first observation
zmbDf = subRegionsDf |>
    dplyr::filter(
        GID_0=="ZMB",
        NAME_2%in%c("Chiengi", "Kaputa")
    ) 

zmbUnion = sf::st_union(zmbDf)

zmbUnionDf = data.frame(
    POLY_ID="zmb_regions_union",
    geom=zmbUnion
) |>
    sf::st_as_sf() |>
    dplyr::rename(geom=geometry)

# DRC Pweto = subregion within haut katanga
pwetoDf = subRegionsDf |>
    dplyr::filter(
        GID_0=="COD",
        NAME_2%in%c("Pweto")
    ) |>
    dplyr::rename(POLY_ID=NAME_2) |>
    dplyr::select(POLY_ID, geom)

# First DRC confirmation (in east) = mulimbi_first_2012
drcEastDf = data.frame(
    POLY_ID="drc_first_east",
    latitude=0.07052,
    longitude=29.04829
)

# North central DRC field experiments = muhindo_optimum_2020
drcCentralDf = data.frame(
    POLY_ID="drc_north_central_field",
    latitude=0.82297222,
    longitude=24.4665278
)

# Gen Sf
nonSfPointsDf = dplyr::bind_rows(
    drcEastDf,
    drcCentralDf
) |>
    sf::st_as_sf(coords=c("longitude", "latitude"), crs="WGS84") |>
    dplyr::rename(geom=geometry)


# Non-published WAVE surveillance in 2015
surveyDf = sf::read_sf("../../../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.gpkg") 

surveyDfSubset = surveyDf |>
    dplyr::filter(
        country_code=="COD",
        year==2015,
        merged_id%in%c("merged_id_13290", "merged_id_13269")
    ) |>
    dplyr::select(merged_id) |>
    dplyr::rename(POLY_ID=merged_id)


# Create df of all points
pointsDf = dplyr::bind_rows(
    nonSfPointsDf
)

# Buffer 100km radius around each point
bufferDf = sf::st_buffer(pointsDf, dist=100000)

# Extract country polygons for countries in host landscape
countryPolysDfDf = countriesDf |>
    dplyr::filter(GID_0%in%hostCountriesCodesDf$POLY_ID) |>
    dplyr::rename(POLY_ID=GID_0) |>
    dplyr::select(POLY_ID, geom)


# Merge all polys
polysDf = dplyr::bind_rows(
    zmbUnionDf,
    pwetoDf,
    bufferDf,
    countryPolysDfDf
)

# Generate host stats
hostRasterPath = "../inputs_raw/host_landscape/CassavaMap/host.tif"

polyDfStats = utils$appendHostStats(
    polyDfIn=polysDf,
    hostRasterPath=hostRasterPath
)

# Save
sf::write_sf(polyDfStats, "../inputs_raw/polygons/polys_cross_continental_constraints_host_CassavaMap.gpkg")
