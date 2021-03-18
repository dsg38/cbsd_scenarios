source("utils.R")
args = commandArgs(trailingOnly = TRUE)

configPath = args[[1]]

configPath = "./inputs_scenarios/2021_03_17_uganda//config.json"

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
}

if(cropBool){
    
    # TODO
    print("PLOT EXTENT")



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


# Survey rasters
if(processSurvey %in% configNames){

    print("SURVEY")

    surveyDir = config[[processSurvey]]

    surveyDirPath = file.path("inputs_raw/survey_rasters/", surveyDir)

    surveyRasterPaths = list.files(surveyDirPath, full.names = TRUE)

    for(surveyRasterPath in surveyRasterPaths){

        print(surveyRasterPath)
        
        # Build out path
        fileName = strsplit(basename(surveyRasterPath), "[.]")[[1]][[1]]
        surveyRasterPathOut = file.path(outDir, paste0(fileName, ".asc"))

        # Process
        processRaster(
            rasterPath = surveyRasterPath,
            extentVec = extentVec,
            cropBool = cropBool,
            pathOut = surveyRasterPathOut
        )
        
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
