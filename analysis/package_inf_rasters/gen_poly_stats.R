args = commandArgs(trailingOnly=TRUE)

configPath = args[[1]]
jobIndex = args[[2]]

# configPath = "./config_poly.json"
# jobIndex = 0

# ---------------------------------
config = rjson::fromJSON(file=configPath)

# Job folder
batchPath = here::here(config[["batchPath"]])
polyDfPath = here::here(config[["polyDfPath"]])
hostRasterPath = here::here(config[["hostRasterPath"]])

# ---------------------------------

jobDir = here::here(batchPath, paste0("job", jobIndex), "output/runfolder0")

# Load polys
polyDf = sf::read_sf(polyDfPath)

# Read in host raster
hostRaster = raster::raster(hostRasterPath, crs="+proj=longlat +datum=WGS84")

# List all rasters
rasterPaths = list.files(jobDir, pattern="O_0_L_0_*_.*.000000.tif", full.names = T, recursive = T)

# Build raster stack
rasterStack = raster::stack(rasterPaths)
raster::crs(rasterStack) = "+proj=longlat +datum=WGS84"

# Calculate num inf fields stack NB: for some reason, this loses the names in the stack
rasterStackNumFields = rasterStack * hostRaster * 1000
names(rasterStackNumFields) = names(rasterStack)

fixColNames = function(df){
    
    oldColNames = colnames(df)
    
    fixedVec = c()    
    for(thisOldName in oldColNames){
        
        thisSplit = strsplit(thisOldName, "\\.")[[1]]
        
        if(length(thisSplit) > 1){
            fixedName = paste0(thisSplit[2:length(thisSplit)], collapse = ".")
            
            fixedVec = c(fixedVec, fixedName)
        }else{
            fixedVec = c(fixedVec, thisOldName)
            
        }

        
    }
    
    return(fixedVec)
    
}

numCellsPopulated = function(values, coverage_fractions){
    return(sum(values>0, na.rm = TRUE))
}


# Sum within each polygon for each raster in the stack. Cols = rasters, rows = polys
rasterPolySumDf = exactextractr::exact_extract(rasterStackNumFields, polyDf, 'sum', stack_apply=TRUE, append_cols=c("GID_0"))

# Rename cols
colnames(rasterPolySumDf) = fixColNames(rasterPolySumDf)

# Calc num cells with any infection
rasterPolyNumPopulatedDf = exactextractr::exact_extract(rasterStackNumFields, polyDf, fun=numCellsPopulated, stack_apply=TRUE, append_cols=c("GID_0"))

# Rename cols
colnames(rasterPolyNumPopulatedDf) = fixColNames(rasterPolyNumPopulatedDf)

# For each raster = columns of extracted dfs
dfList = list()
for(rasterPath in rasterPaths){

    rasterPathNorm = normalizePath(rasterPath)
    print(rasterPathNorm)
    
    splitPath = strsplit(rasterPathNorm, "*/")[[1]]
    
    job = dplyr::nth(splitPath, -4)
    batch = dplyr::nth(splitPath, -5)
    scenario = dplyr::nth(splitPath, -6)
    
    # Get year
    rasterFilenameNoExt = tools::file_path_sans_ext(basename(rasterPathNorm))
    splitFilename = strsplit(rasterFilenameNoExt, "_")[[1]]
    raster_year = as.numeric(dplyr::last(splitFilename))
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
    
    sf::st_geometry(thisRasterDf) = NULL
    
    dfList[[rasterPathNorm]] = thisRasterDf
    
}

outDf = dplyr::bind_rows(dfList)

outPath = here::here(jobDir, "results_poly_stats.csv")
write.csv(outDf, outPath, row.names = FALSE)
