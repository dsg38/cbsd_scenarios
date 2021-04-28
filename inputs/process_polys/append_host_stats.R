box::use(./utils)
args = commandArgs(trailingOnly=TRUE)

# Read in config
configPath = args[[1]]

config = rjson::fromJSON(file=configPath)

# Specify list of poly dfs to merge
polyDfPathVec = here::here(config[["polyDfPathVec"]])

# Specify gpkg out path
polyDfPathOut = here::here(config[["polyDfPathOut"]])

# Specify host landscape path
hostRasterPath = here::here(config[["hostRasterPath"]])

# -------------------------------------

# Merge sf dfs
polyDfInList = list()
for(polyDfPathIn in polyDfPathVec){
    polyDfInList[[polyDfPathIn]] = sf::st_read(polyDfPathIn)
}

polyDfIn = dplyr::bind_rows(polyDfInList)

# Read in host raster
hostRaster = raster::raster(hostRasterPath)

# Calc num fields
polyHostNumFields = exactextractr::exact_extract(hostRaster, polyDfIn, fun='sum') * 1000

# Calc num cells populated
polyNumCellsWithHost = exactextractr::exact_extract(hostRaster, polyDfIn, fun=utils$numCellsPopulated)

# Calc num cells total
polyNumCellsInPoly = exactextractr::exact_extract(hostRaster, polyDfIn, fun=utils$numCellsInPoly)

# Build out df
polySumDf = cbind(
    polyDfIn, 
    cassava_host_num_fields=polyHostNumFields,
    cassava_host_num_cells_with_host=polyNumCellsWithHost,
    cassava_host_num_cells_in_poly=polyNumCellsInPoly
)

# Save
sf::st_write(polySumDf, polyDfPathOut, append=FALSE)
