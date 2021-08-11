# ----------------------------------------------------
# Aggragate and crop rasters pre-sim survey analysis
# ----------------------------------------------------
# Build filepaths to all the rasters that meet the criteria
# for sim surveillance analysis. Then crop them and copy them
# to a single dir.
# ----------------------------------------------------
box::use(utils_epidem/utils_epidem)
box::reload(utils_epidem)

passDf = read.csv("./outputs/nga_arrival.csv")

# HACK!
passDf = passDf[1:2,]

scenarioName = "2021_03_26_cross_continental"
prefix = "O_0_L_0_INFECTIOUS_"
suffix = ".000000.tif"

# Get crop extent
country_code_vec = c("NGA", "CMR")

extent_bbox = utils_epidem$get_extent_country_code_vec(country_code_vec)

# -------------------------------------------------------

topDir = here::here("simulations", "sim_output", "scenarioName")
copyDir = here::here("analysis", "surveillance", "output", scenarioName, "rasters")

dir.create(copyDir, showWarnings = FALSE, recursive = TRUE)

for(iRow in seq_len(nrow(passDf))){
    
    thisRow = passDf[iRow,]
    
    thisJobDir = here::here(topDir, thisRow$batch, thisRow$job, "output", "runfolder0")
    
    # Build raster paths
    startYear = thisRow$raster_year
    endYear = startYear + 4
    
    rasterYears = seq(startYear, endYear)
    
    for(thisRasterYear in rasterYears){
        
        raster_path = here::here(thisJobDir, paste0(prefix, thisRasterYear, suffix))
        outPath = here::here(copyDir, paste0(thisRow$batch, "-", thisRow$job, "-", "INF", "-", thisRasterYear, ".tif"))

        if(!file.exists(raster_path)){
            print(raster_path)
            stop("`raster_path` missing")
        }
        
        # Crop
        raster_cropped = utils_epidem$crop_raster_extent(
            raster_path=raster_path,
            extent_bbox=extent_bbox
        )

        # Save
        raster::writeRaster(raster_cropped, outPath)
        
    }

}
