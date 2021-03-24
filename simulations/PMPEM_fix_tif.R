options(stringsAsFactors = FALSE)

topDir = "./sim_output/2021_03_17_cross_continental/"
# 
# fixRasterPaths = function(txtRasterPaths){
#     
#     # Randomise the order
#     txtRasterPaths = sample(txtRasterPaths)
#     
#     fixCount = 0
#     for(thisRasterPath in txtRasterPaths){
#         
#         rasterCreated = file.info(thisRasterPath)$ctime
#         
#         # Check still exists
#         if(!is.na(rasterCreated)){
#             
#             timeDiff = Sys.time() - rasterCreated
#             numSecs = as.numeric(timeDiff, units = "secs")
#             
#             # Check file old enough
#             if(numSecs > 1000){
#                 
#                 print(thisRasterPath)
#                 
#                 # Read raster
#                 thisRaster = raster::raster(thisRasterPath)
#                 
#                 outRasterPath = gsub(".txt", ".tif", thisRasterPath)
#                 
#                 # Write out as tif
#                 raster::writeRaster(thisRaster, outRasterPath, overwrite=TRUE)
#                 
#                 # Delete old raster
#                 file.remove(thisRasterPath)
#                 
#                 fixCount = fixCount + 1
#                 print(fixCount)
#                 
#             }
#             
#             print("NUM LEFT TO FIX:")
#             print(length(txtRasterPaths) - fixCount)
#             
#         }
#         
#     }
#     
# }
# 
# # Get all txt rasters
# txtRasterPaths = list.files(topDir, pattern="O_0_L_0_INFECTIOUS_.*.000000.txt", full.names = T, recursive = T)
# 
# fixRound = 0
# while(length(txtRasterPaths) > 0){
#     
#     print("FIX ROUND:")
#     print(fixRound)
#     
#     fixRasterPaths(txtRasterPaths)
#     
#     # Regen list
#     txtRasterPaths = list.files(topDir, pattern="O_0_L_0_INFECTIOUS_.*.000000.txt", full.names = T, recursive = T)
#     
#     fixRound = fixRound + 1
#     
# }

