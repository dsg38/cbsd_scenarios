box::use(./utils)

countriesDf = sf::read_sf("./gadm36_levels_gpkg/gadm36_level0_africa.gpkg")

# Filter out Rwanda + Burundi
rwaBwiDf = countriesDf |>
    dplyr::filter(GID_0%in%c("RWA", "BDI")) |>
    dplyr::rename(POLY_ID=GID_0) |>
    dplyr::select(POLY_ID, geom)


# Zambian small regions of first observation
subRegionsDf = sf::read_sf("./gadm36_levels_gpkg/gadm36_level2_africa.gpkg")

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

# DRC southern observations in Haut Katanga = casingaExpansionCassavaBrown2020
regionsDf = sf::read_sf("./gadm36_levels_gpkg/gadm36_level1_africa.gpkg")

hkDf = regionsDf |>
    dplyr::filter(
        GID_0=="COD",
        NAME_1=="Haut-Katanga"
    ) |>
    dplyr::rename(POLY_ID=NAME_1) |>
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
    nonSfPointsDf,
    surveyDfSubset
)

# Buffer 100km radius around each point
bufferDf = sf::st_buffer(pointsDf, dist=100000)

# mapview::mapview(bufferDf)

# Merge all polys
polysDf = dplyr::bind_rows(
    rwaBwiDf,
    zmbUnionDf,
    hkDf,
    bufferDf
)

# mapview::mapview(polysDf)

# Generate host stats
hostRasterPath = "../inputs_raw/host_landscape/CassavaMap/host.tif"

polyDfStats = utils$appendHostStats(
    polyDfIn=polysDf,
    hostRasterPath=hostRasterPath
)

# Save
sf::write_sf(polyDfStats, "../inputs_raw/polygons/polys_cross_continental_constraints_host_CassavaMap.gpkg")
