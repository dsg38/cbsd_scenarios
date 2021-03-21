source("utils.R")
library(dplyr)
args = commandArgs(trailingOnly = TRUE)

# configPath = "inputs_scenarios/2021_03_18_nigeria_region/config.json"
# configPath = "inputs_scenarios/2021_03_17_cross_continental/config.json"
configPath = args[[1]]

# Define keys
processHost = "processHost"
processInit = "processInit"
processSurvey = "processSurvey"
processVector = "processVector"
copyGeneralFiles = "copyGeneralFiles"

# Read config
config = my::readJsonFile(configPath)

# NB: Assumes config is in scenario dir
outDir = file.path(dirname(configPath), "inputs")
dir.create(outDir, showWarnings = FALSE)

# Parse extent
extentVec = getExtentVecFromConfig(config)

# If extent specified, crop - else just copy
cropBool = !is.null(extentVec)

# Work out which to process
configNames = names(config)

writeRasterCustom = function(rasterOut, pathOut, renameBool = FALSE){
    
    if(renameBool){
        pathOutTemp = gsub(".txt", ".asc", pathOut)
        
        raster::writeRaster(rasterOut, pathOutTemp, overwrite=TRUE)
        renameSuccessBool = file.rename(pathOutTemp, pathOut)
        
        stopifnot(renameSuccessBool)
        
    }else{
        
        raster::writeRaster(rasterOut, pathOut, overwrite=TRUE)
        
    }
    
    
}

processRaster = function(rasterPath, extentVec, cropBool, pathOut, renameBool = FALSE){
    
    rasterIn = raster::raster(rasterPath)
    
    if(cropBool){
        rasterOut = raster::crop(rasterIn, extentVec)
    }else{
        rasterOut = rasterIn
    }
    
    writeRasterCustom(
        rasterOut = rasterOut,
        pathOut = pathOut,
        renameBool = renameBool
    )

    return(rasterOut)
}

if(cropBool){
    
    print("PLOT EXTENT")
    plotPathOut = file.path(outDir, "extent.png")
    
    africaPolys = my::loadPolysAfrica()
    
    df = data.frame(
        lat=c(extentVec[["ymax"]], extentVec[["ymax"]], extentVec[["ymin"]], extentVec[["ymin"]]),
        lng=c(extentVec[["xmin"]], extentVec[["xmax"]], extentVec[["xmax"]], extentVec[["xmin"]]),
        id=c("A", "B", "C", "D"),
        row.names = NULL
    )
    
    polygonDf = sfheaders::sf_polygon(df, x = "lng", y = "lat", keep = TRUE)
    
    sf::st_crs(polygonDf) = my::getWgsCode()
    
    tm = tmap::tm_shape(africaPolys) +
        tmap::tm_polygons() +
        tmap::tm_shape(polygonDf) +
        tmap::tm_borders(col="red", lwd=5)
    
    tmap::tmap_save(
        tm=tm,
        filename=plotPathOut
    )

}

# Host raster
if(processHost %in% configNames){
    
    print("HOST")
    
    hostDir = config[[processHost]]
    
    hostPath = file.path("inputs_raw/host_landscape", hostDir, "host.tif")
    
    hostPathOut = file.path(outDir, "L_0_HOSTDENSITY.txt")
    
    # Process
    processRaster(
        rasterPath = hostPath,
        extentVec = extentVec,
        cropBool = cropBool,
        pathOut = hostPathOut,
        renameBool = TRUE
    )
    
}

# Init conditions
if(processInit %in% configNames){
    
    print("INIT")
    
    initDir = config[[processInit]]
    
    initDirPath = file.path("inputs_raw/init_conditions", initDir)
    
    initFileNamesList = list()
    initFileNamesList[["inf_raster.tif"]] = "L_0_INFECTIOUS.txt"
    initFileNamesList[["sus_raster.tif"]] = "L_0_SUSCEPTIBLE.txt"
    initFileNamesList[["rem_raster.tif"]] = "L_0_REMOVED.txt"
        
    for(initFileName in names(initFileNamesList)){
        
        initRasterPath = file.path(initDirPath, initFileName)
        initRasterPathOut = file.path(outDir, initFileNamesList[[initFileName]])
        
        print(initRasterPath)
        
        # Process
        processRaster(
            rasterPath = initRasterPath,
            extentVec = extentVec,
            cropBool = cropBool,
            pathOut = initRasterPathOut,
            renameBool = TRUE
        )

    }
    
}


extractIndex = function(thisRaster){
  
  thisRaster = surveyRasterOut
  
  zeroExtent = raster::extent(0, raster::xmax(thisRaster)-raster::xmin(thisRaster), 0, raster::ymax(thisRaster)-raster::ymin(thisRaster))
  
  raster::extent(thisRaster) = zeroExtent
  
  rasterIndexes = which(thisRaster[]>0)
  numRealSurveysInCell = thisRaster[rasterIndexes]
  
  indexDf = as.data.frame(raster::rowColFromCell(thisRaster, rasterIndexes))
  indexDf = indexDf %>% dplyr::rename("X"="col", "Y"="row")
  indexDf = cbind(indexDf, numRealSurveysInCell)
  
  # Correct offset
  indexDf$X = indexDf$X - 1
  indexDf$Y = indexDf$Y - 1
  
  return(indexDf)
  
}

# Survey rasters
if(processSurvey %in% configNames){

    print("SURVEY")

    surveyDir = config[[processSurvey]]

    surveyDirPath = file.path("inputs_raw/survey_rasters/", surveyDir)

    surveyRasterPaths = list.files(surveyDirPath, full.names = TRUE)

    polygonPaths = list.files("../inputs/inputs_raw/masks/", full.names=T)

    # Masks out path
    outPathMasks = file.path(dirname(outDir), "masks")
    dir.create(outPathMasks, showWarnings = FALSE)

    for(surveyRasterPath in surveyRasterPaths){

        print(surveyRasterPath)
        
        # Build out path
        fileName = strsplit(basename(surveyRasterPath), "[.]")[[1]][[1]]
        surveyRasterPathOut = file.path(outDir, paste0(fileName, ".asc"))

        # Process
        surveyRasterOut = processRaster(
            rasterPath = surveyRasterPath,
            extentVec = extentVec,
            cropBool = cropBool,
            pathOut = surveyRasterPathOut
        )

        # Build survey index dfs
        indexDf = extractIndex(surveyRasterOut)
        outIndexPath = file.path(outPathMasks, gsub(".tif", ".csv", basename(surveyRasterPath)))
        write.csv(indexDf, outIndexPath, row.names = F)

        thisRasterYear = gsub("_raster_total.tif", "", basename(surveyRasterPath))

        # Build indexes for poly mask
        for(thisPolygonPath in polygonPaths){
        
            print(thisPolygonPath)
        
            thisPolygonName = basename(thisPolygonPath)
            thisPolygonStr = gsub(".rds", "", thisPolygonName)
        
            thisPolygon = readRDS(thisPolygonPath)
        
            thisPolyRaster = raster::mask(surveyRasterOut, thisPolygon, updateValue=0)
            thisPolyIndexDf = extractIndex(thisPolyRaster)
        
            outPolyIndexPath = file.path(outPathMasks, paste0(thisRasterYear, "_", thisPolygonStr, ".csv"))
            write.csv(thisPolyIndexDf, outPolyIndexPath, row.names = F)
            
        }
        
    }

}

# Vector
if(processVector %in% configNames){
    
    print("VECTOR")
    
    vectorDir = config[[processVector]]
    
    vectorRasterPath = file.path("inputs_raw/vector", vectorDir, "vector.tif")
    
    vectorRasterPathOut = file.path(outDir, "vector.asc")
    
    # Process
    processRaster(
        rasterPath = vectorRasterPath,
        extentVec = extentVec,
        cropBool = cropBool,
        pathOut = vectorRasterPathOut
    )
    
}

# Copy general files
if(copyGeneralFiles %in% configNames){
    
    print("COPY")
    
    copyFilesList = config[[copyGeneralFiles]]
    
    for(fileNameIn in names(copyFilesList)){
        
        filePathIn = file.path("inputs_raw/general_files", fileNameIn)
        filePathOut = file.path(outDir, copyFilesList[[fileNameIn]])
        
        file.copy(filePathIn, filePathOut, overwrite = TRUE)
        
    }
    
}
