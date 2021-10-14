box::use(utils_epidem/utils_epidem)
africaPolys = utils_epidem$getAfricaPolys()

x = sf::read_sf("./polys_2_host_default.gpkg")

# plot(sf::st_geometry(x))
# utils::View(x)

y = x[x$POLY_ID=="mask_drc_central_small",]


plot(sf::st_geometry(africaPolys))
plot(sf::st_geometry(y), add=TRUE, col="green")
