library(raster)

initialInfectionProportion = 0.01

baseInputsDir = "scenario_10_inputs/"

s_10_host = raster(paste0(baseInputsDir, "L_0_HOSTDENSITY.txt"))

s_10_infection = raster(paste0(baseInputsDir, "L_0_INFECTIOUS.txt"))

vectorFileName = paste0(baseInputsDir, "whiteflyNormalisedAfrica.txt")
s_10_vector = raster(vectorFileName)

envFileName = paste0(baseInputsDir, "P_WeatherSwitchTimes.txt")

portLocations = list("Nigeria" = c(3.3679469694133735, 6.55757835306778),
                     "Gabon" = c(9.485321893677751, 0.3871568633133535),
                     "Cameroon" = c(9.73776411214862, 4.017771710250692),
                     "Benin" = c(2.3851887166993513, 6.386840723566606),
                     "Togo" = c(1.3707565013918002, 6.403115930139983),
                     "Ghana" = c(-0.18675893538821092, 5.56998252166719),
                     "IvoryCoast" = c(-4.002813345208759, 5.340449837259588)
                     )

#Wrapper to write an ascii raster with a .txt extension (otherwise it would append .asc automatically no matter what)
writeRasterTxt = function(x, fileName) {
  #Writing temp files via /tmp seems to give horrific results on the HPC, so we'll try and write via the local directory instead
  tempRasterFileName = tempfile("tempRaster", fileext = ".asc", tmpdir = ".")
  
  print(paste0("Writing raster ", fileName, " via temp file ", tempRasterFileName, " because the R raster package can't save an ascii raster with a txt extension"))
  writeRaster(x = x, filename = tempRasterFileName)
  
  
  print(paste0("Moving temp raster ", tempRasterFileName, " to final raster ", fileName))
  file.rename(from = tempRasterFileName, to = fileName)
  #NOTE that while file.rename (i.e. move) is what is wanted here, that fails with the error message "cannot rename file reason 'Invalid cross-device link'" which is total nonsense but is apparently caused by having an encrypted home folder, as is present on the UCam HPC
  #file.copy(from = tempRasterFileName, to = fileName, overwrite = TRUE)
}


#Cut data to West Africa Extent
#reducedExtent = extent(c(xmin = -14.0787152352959, xmax = 17.773800157979114, ymin = -5.287481254957122, ymax = 15.696357127451886)
#TODO: inteersect extent with host extent to get actual extent programatically rather than manually
cropExtent = extent(c(xmin = -8.7, xmax = 17.7, ymin = -5.3, ymax = 15.5))

crop_Host = crop(x = s_10_host, y = cropExtent)
crop_Infection = crop(x = s_10_infection, y = cropExtent)
crop_vector = crop(x = s_10_vector, y = cropExtent)

#For each CBSD-free WAVE country, create an introduction site at a major port 
for(country in names(portLocations)) {
  
  location = portLocations[[country]]
  locationX = location[1]
  locationY = location[2]
  
  viewRange = 0.5
  
  nearPortExtent = c(xmin = locationX - viewRange, xmax = locationX + viewRange, ymin = locationY - viewRange, ymax = locationY + viewRange)
  
  
  nearHost = crop(x = crop_Host, y = nearPortExtent)
  
  #Sample a location that has host
  nearHostPoints = rasterToPoints(nearHost)
  
  #TODO: Bias to high density areas: ate last half of max denisty in area i.e. > 0.75 nearhostPoints[, 3]
  viableHostThreshold = 0.75 * max(nearHostPoints[,3])
  viableHostPoints = nearHostPoints[nearHostPoints[,3] >= viableHostThreshold, ]
  
  randomRow = sample(x = seq_len(nrow(viableHostPoints)), size = 1, replace = FALSE, prob = viableHostPoints[, 3])
  randomX = viableHostPoints[randomRow, 1]
  randomY = viableHostPoints[randomRow, 2]
  
  newIC = crop_Infection
  
  randomCell = cellFromXY(newIC, xy = c(randomX, randomY))
  
  newIC[randomCell] = initialInfectionProportion
  
  #Plot IC raster:
  #plot(newIC, xlim = c(nearPortExtent[1], nearPortExtent[2]), ylim = c(nearPortExtent[3], nearPortExtent[4]), main = paste0("Introduction location - ", country))
  
  plot(crop_Host, xlim = c(nearPortExtent[1], nearPortExtent[2]), ylim = c(nearPortExtent[3], nearPortExtent[4]), main = paste0("Introduction location - ", country), sub = paste0("x= ", randomX, " y=", randomY))
  
  points(x = randomX, y = randomY, pch = "+", col = "red", cex = 2)
  
  outDir = paste0("Introduction_", country, "/")
  
  if(!dir.exists(outDir)) {
    dir.create(path = outDir, showWarnings = TRUE, recursive = TRUE)
  }
  
  #Create corresponding S raster
  new_S = 1.0 - newIC
  
  
  #Write output files;
  writeRasterTxt(x = newIC, fileName = paste0(outDir, "L_0_INFECTIOUS.txt"))
  writeRasterTxt(x = new_S, fileName = paste0(outDir, "L_0_SUSCEPTIBLE.txt"))
  
  writeRasterTxt(x = crop_Host, fileName = paste0(outDir, "L_0_HOSTDENSITY.txt"))
  
  file.copy(from = vectorFileName, to = paste0(outDir, basename(vectorFileName)), overwrite = TRUE)
  file.copy(from = envFileName, to = paste0(outDir, basename(envFileName)), overwrite = TRUE)
}



