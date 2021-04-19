library(dplyr)
library(raster)
library(sf)
library(exactextractr)
library(rjson)
box::use(./utils_analysis)
args = commandArgs(trailingOnly=TRUE)

configPath = args[[1]]
jobIndex = args[[2]]

# ---------------------------------
config = fromJSON(file=configPath)

# Job folder
batchPath = here::here(config[["batchPath"]])
polyDfPath = here::here(config[["polyDfPath"]])
hostRasterPath = here::here(config[["hostRasterPath"]])

# ---------------------------------

jobDir = here::here(batchPath, paste0("job", jobIndex), "output/runfolder0")

# Load polys
polyDf = st_read(polyDfPath)

# Read in host raster
hostRaster = raster(hostRasterPath)
crs(hostRaster) = CRS('+init=EPSG:4326')

# List all rasters
rasterPaths = list.files(jobDir, pattern="O_0_L_0_*_.*.000000.tif", full.names = T, recursive = T)

# Build raster stack
rasterStack = stack(rasterPaths)
crs(rasterStack) = CRS('+init=EPSG:4326')

# Calculate num inf fields stack NB: for some reason, this loses the names in the stack
rasterStackNumFields = rasterStack * hostRaster * 1000
names(rasterStackNumFields) = names(rasterStack)

fixColNames = function(df){
    
    oldColNames = colnames(df)
    
    fixedVec = c()    
    for(thisOldName in oldColNames){
        
        thisSplit = strsplit(thisOldName, "\\.")[[1]]
        fixedName = paste0(thisSplit[2:length(thisSplit)], collapse = ".")
        
        fixedVec = c(fixedVec, fixedName)
        
    }
    
    return(fixedVec)
    
}

# Sum within each polygon for each raster in the stack. Cols = rasters, rows = polys
rasterPolySumDf = exact_extract(rasterStackNumFields, polyDf, 'sum', stack_apply=TRUE)

# Rename cols
colnames(rasterPolySumDf) = fixColNames(rasterPolySumDf)

# Calc num cells with any infection
rasterPolyNumPopulatedDf = exact_extract(rasterStackNumFields, polyDf, fun=utils_analysis$numCellsPopulated, stack_apply=TRUE)

# Rename cols
colnames(rasterPolyNumPopulatedDf) = fixColNames(rasterPolyNumPopulatedDf)

dfList = list()
for(rasterPath in rasterPaths){

    rasterPathNorm = normalizePath(rasterPath)
    print(rasterPathNorm)
    
    splitPath = strsplit(rasterPathNorm, "*/")[[1]]
    
    job = nth(splitPath, -4)
    batch = nth(splitPath, -5)
    scenario = nth(splitPath, -6)
    
    # Get year
    rasterFilenameNoExt = tools::file_path_sans_ext(basename(rasterPathNorm))
    splitFilename = strsplit(rasterFilenameNoExt, "_")[[1]]
    raster_year = as.numeric(last(splitFilename))
    raster_type = splitFilename[[5]]
        
    # Calc stats
    raster_num_fields = rasterPolySumDf[[rasterFilenameNoExt]]

    raster_prop_fields = raster_num_fields / polyDf$cassava_host_num_fields
    raster_prop_fields[is.na(raster_prop_fields)] = 0

    # Add in num cells stats
    raster_num_cells_populated = rasterPolyNumPopulatedDf[[rasterFilenameNoExt]]
        
    # Build out df
    thisRasterDf = cbind(
        polyDf,
        raster_num_fields=raster_num_fields,
        raster_prop_fields=raster_prop_fields,
        raster_num_cells_populated=raster_num_cells_populated,
        raster_year=raster_year,
        raster_type=raster_type,
        job=job,
        batch=batch,
        scenario=scenario,
        raster_path=rasterPathNorm
    )
    
    st_geometry(thisRasterDf) = NULL
    
    dfList[[rasterPathNorm]] = thisRasterDf
    
}

outDf = bind_rows(dfList)

outPath = here::here(jobDir, "results_poly_stats.csv")
write.csv(outDf, outPath, row.names = FALSE)
