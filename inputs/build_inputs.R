box::use(./utils)
box::use(utils_epidem/utils_epidem)
args = commandArgs(trailingOnly = TRUE)

# configPath = "inputs_scenarios/2021_03_18_nigeria_region/config.json"
# configPath = "inputs_scenarios/2021_03_17_cross_continental_TEST/config.json"
configPath = args[[1]]

# Define keys
processHost = "processHost"
processInit = "processInit"
processSurvey = "processSurvey"
processVector = "processVector"
copyGeneralFiles = "copyGeneralFiles"

# Read config
config = utils_epidem$readJsonFile(configPath)

# NB: Assumes config is in scenario dir
outDir = file.path(dirname(configPath), "inputs")
dir.create(outDir, showWarnings = FALSE)

# Parse extent
extentVec = utils$getExtentVecFromConfig(config)

# If extent specified, crop - else just copy
cropBool = !is.null(extentVec)

# Work out which to process
configNames = names(config)

# Build extent poly
extentPolygonDfSt = data.frame(
    lat=c(extentVec[["ymax"]], extentVec[["ymax"]], extentVec[["ymin"]], extentVec[["ymin"]]),
    lng=c(extentVec[["xmin"]], extentVec[["xmax"]], extentVec[["xmax"]], extentVec[["xmin"]]),
    id=c("A", "B", "C", "D"),
    row.names = NULL
)

extentPolygonDf = sfheaders::sf_polygon(extentPolygonDfSt, x = "lng", y = "lat", keep = TRUE)

sf::st_crs(extentPolygonDf) = "WGS84"

if(cropBool){
    
    print("PLOT EXTENT")
    plotPathOut = file.path(outDir, "extent.png")
    
    africaPolys = utils_epidem$getAfricaPolys()
    
    tm = tmap::tm_shape(africaPolys) +
        tmap::tm_polygons() +
        tmap::tm_shape(extentPolygonDf) +
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
    utils$processRaster(
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
        utils$processRaster(
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

    surveyConfig = config[[processSurvey]]
    surveyDir = surveyConfig[["surveyDir"]]
    polyDfName = surveyConfig[["polyDfName"]]

    surveyDirPath = file.path("inputs_raw/survey_rasters/", surveyDir)
    surveyPolysDfPath = file.path("inputs_raw/polygons/", polyDfName)

    # Check that all mask polys inside scenario extent
    polysInExtentBool = utils$checkPolysInExtent(
        surveyPolysDfPath=surveyPolysDfPath,
        extentPolygonDf=extentPolygonDf
    )

    stopifnot(polysInExtentBool)

    # Crop survey rasters
    surveyRasterPaths = list.files(surveyDirPath, full.names = TRUE)

    for(surveyRasterPath in surveyRasterPaths){
        
        print(surveyRasterPath)
        
        surveyRasterFileName = tools::file_path_sans_ext(basename(surveyRasterPath))
        
        surveyRasterPathOut = file.path(outDir, paste0(surveyRasterFileName, ".asc"))
        
        utils$processRaster(
            rasterPath = surveyRasterPath,
            extentVec = extentVec,
            cropBool = cropBool,
            pathOut = surveyRasterPathOut
        )

    }

    # Build indexes for cropped survey rasters (i.e. specify XY raster cell indexes for survey points in each poly)
    outIndexDir = file.path(dirname(configPath), "survey_poly_index")

    utils$genPolyIndex(
        surveyRasterDir=outDir,
        polyDfPath=surveyPolysDfPath,
        outIndexDir=outIndexDir
    )

}

# Vector
if(processVector %in% configNames){
    
    print("VECTOR")
    
    vectorDir = config[[processVector]]
    
    vectorRasterPath = file.path("inputs_raw/vector", vectorDir, "vector.tif")
    
    vectorRasterPathOut = file.path(outDir, "vector.asc")
    
    # Process
    utils$processRaster(
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
