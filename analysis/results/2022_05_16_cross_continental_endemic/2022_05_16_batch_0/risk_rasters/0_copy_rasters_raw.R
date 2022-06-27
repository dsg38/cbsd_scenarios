args = commandArgs(trailingOnly=TRUE)

simDir = "../../../../../simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/"
rasterYear = args[[1]]

# rasterYear = 2023

# Def out dir
outDir = file.path("./raw/", paste0("inf_rasters_", rasterYear))
dir.create(outDir, recursive = TRUE, showWarnings = FALSE)

# List target rasters
rasterPaths = list.files(simDir, paste0("O_0_L_0_INFECTIOUS_", rasterYear, ".000000.tif"), recursive = TRUE, full.names = TRUE)

if(any(stringr::str_detect(rasterPaths, ".xml"))){
    stop("Stopped as read in xml metadata files")
}

print("About to copy:")
print(length(rasterPaths))

print("Copying")
i = 0
for(rasterPath in rasterPaths){
    print(i)
    
    outPath = file.path(outDir, basename(rasterPath))
    
    file.copy(from=rasterPath, to=outPath, overwrite = TRUE)
    
    i = i + 1
    
}









#: Pull out rasters that pass target criteria




# rasterStack = raster::stack(rasterPaths)

# # Convert each raster to bool presence/absence



# # Calc mean = prob that a given raster cell is infected at a given time


# tic()
# sumRaster = raster::calc(rasterStack, mean, na.rm=TRUE)
# toc()

# tic()
# x = mean(rasterStack, na.rm=TRUE)
# toc()
# # "../../../../simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/job0/output/runfolder0/O_0_L_0_INFECTIOUS_2023.000000.tif"

# : Is sum loop faster?
# # x = rasterStack[[1]]
# # tic()
# # for()
