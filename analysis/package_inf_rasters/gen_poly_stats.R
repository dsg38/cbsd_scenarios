box::use(tictoc[tic, toc])

tic(msg="total")

args = commandArgs(trailingOnly=TRUE)

configPath = args[[1]]
jobIndex = args[[2]]

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

# Define func to work out num populated cells
numCellsPopulated = function(values, coverage_fractions){
    return(sum(values>0, na.rm = TRUE))
}

# Calc poly stats for each raster
tic(msg="extract")
rasterDfList = list()
for(rasterPath in rasterPaths){

    print(rasterPath)

    thisRasterRaw = raster::raster(rasterPath, crs="+proj=longlat +datum=WGS84")
    thisRaster = thisRasterRaw * hostRaster * 1000

    # Sum within each polygon
    tic(msg="sum_loop")
    rasterPolySumDf = exactextractr::exact_extract(
        thisRaster,
        polyDf,
        'sum',
        stack_apply=TRUE,
        append_cols=c("POLY_ID")
    )
    
    rasterPolySumDf = dplyr::rename(rasterPolySumDf, "raster_num_fields" = 2)

    toc()

    # Calc num cells with any infection
    tic(msg="pop_loop")
    rasterPolyNumPopulatedDf = exactextractr::exact_extract(
        thisRaster, 
        polyDf, 
        fun=numCellsPopulated, 
        stack_apply=TRUE, 
        append_cols=c("POLY_ID")
    )

    rasterPolyNumPopulatedDf = dplyr::rename(rasterPolyNumPopulatedDf, "raster_num_cells_populated" = 2)

    toc()
    
    mergedDf = dplyr::full_join(rasterPolySumDf, rasterPolyNumPopulatedDf, by="POLY_ID")
    
    rasterDfList[[rasterPath]] = mergedDf

}
toc()

# Drop poly geom to speed up
sf::st_geometry(polyDf) = NULL

# NB: Are these two identical loops split for memory reasons or can they be merged?

# Build output stats
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
        
    # Pull out corresponding raster stats df
    rasterStatsDf = rasterDfList[[rasterPath]]

    # Join by matching column
    rasterStatsPolyDfPartial = dplyr::full_join(polyDf, rasterStatsDf, by="POLY_ID")

    # Calc prop fields
    raster_prop_fields = rasterStatsPolyDfPartial$raster_num_fields / rasterStatsPolyDfPartial$cassava_host_num_fields
    raster_prop_fields[is.na(raster_prop_fields)] = 0
    
    rasterStatsPolyDf = cbind(rasterStatsPolyDfPartial, raster_prop_fields)
    
    # Build out df
    thisRasterDf = cbind(
        rasterStatsPolyDf,
        raster_year=raster_year,
        raster_type=raster_type,
        job=job,
        batch=batch,
        scenario=scenario,
        raster_path=rasterPathNorm
    )
    
    dfList[[rasterPathNorm]] = thisRasterDf
    
}

outDf = dplyr::bind_rows(dfList)

outPath = here::here(jobDir, "raster_poly_stats.rds")
print(outPath)

saveRDS(outDf, outPath)

toc()
