# Specify num inf fields
numFields = 5

# Square radius around coordinate
viewRange = 0.5

# Define general simulation extent
cropExtent = raster::extent(c(xmin = -8.7, xmax = 17.7, ymin = -5.3, ymax = 15.5))

hostRasterPath = "../../host_landscape/CassavaMap-cassava_data-2022_02_09/host.tif"

# ----------------------

hostRaster = raster::raster(hostRasterPath)

# Create empty inf raster at same extent as host
infRaster = hostRaster
infRaster[] = 0

# Define port locations
portLocations = list(
    "Nigeria" = c(3.3679469694133735, 6.55757835306778),
    "Gabon" = c(9.485321893677751, 0.3871568633133535),
    "Cameroon" = c(9.73776411214862, 4.017771710250692),
    "Benin" = c(2.3851887166993513, 6.386840723566606),
    "Togo" = c(1.3707565013918002, 6.403115930139983),
    "Ghana" = c(-0.18675893538821092, 5.56998252166719),
    "IvoryCoast" = c(-4.002813345208759, 5.340449837259588)
)

# Cut data to West Africa Extent
# TODO: inteersect extent with host extent to get actual extent programatically rather than manually

hostRasterCrop = raster::crop(x = hostRaster, y = cropExtent)
infRasterCrop = raster::crop(x = infRaster, y = cropExtent)

# For each CBSD-free WAVE country, create an introduction site at a major port 
# for(country in names(portLocations)) {
country = "Nigeria"

# Pull out target coords
location = portLocations[[country]]
locationX = location[1]
locationY = location[2]

# Define extent where infected field(s) can be located
nearPortExtent = c(xmin = locationX - viewRange, xmax = locationX + viewRange, ymin = locationY - viewRange, ymax = locationY + viewRange)

# Extract this small square of host landscape where new field(s) are allowed
nearHost = raster::crop(x = hostRasterCrop, y = nearPortExtent)

# Convert this small chunk of host to an x/y/host_val dataframe
nearHostPoints = raster::rasterToPoints(nearHost)

#TODO: Bias to high density areas: at least half of max denisty in area i.e. > 0.75
viableHostThreshold = 0.75 * max(nearHostPoints[,3])
viableHostPoints = nearHostPoints[nearHostPoints[,3] >= viableHostThreshold, ]

# Sample a location that has host
randomRow = sample(x = seq_len(nrow(viableHostPoints)), size = numFields, replace = FALSE, prob = viableHostPoints[, 3])
randomX = viableHostPoints[randomRow, 1]
randomY = viableHostPoints[randomRow, 2]

# 
randomCell = raster::cellFromXY(infRasterCrop, xy = cbind(randomX, randomY))

# Calculate the number of fields in the host raster in each cell
hostRasterCropNumFields = ceiling(1000 * hostRasterCrop)
numFieldsAtCellIndexes = hostRasterCropNumFields[randomCell]

# Calculate the proportion that would be equiv to one field given the num fields in the host raster
propThatIsOneFieldVec = 1 / numFieldsAtCellIndexes

# Drop this proportion into the inf raster
infRasterCrop[randomCell] = propThatIsOneFieldVec

# How many seeded?
raster::cellStats(infRasterCrop, 'sum', asSample=FALSE)

# Plot IC raster:
raster::plot(hostRasterCrop, xlim = c(nearPortExtent[1], nearPortExtent[2]), ylim = c(nearPortExtent[3], nearPortExtent[4]), main = paste0("Introduction location - ", country), sub = paste0("x= ", randomX, " y=", randomY))

points(x = randomX, y = randomY, pch = "+", col = "red", cex = 2)

#Create corresponding S raster
new_S = 1.0 - infRasterCrop


# -----------------------------





# ----------------------------
# outDir = paste0("Introduction_", country, "/")

# if(!dir.exists(outDir)) {
#     dir.create(path = outDir, showWarnings = TRUE, recursive = TRUE)
# }


#Write output files;
#   writeRasterTxt(x = infRasterCrop, fileName = paste0(outDir, "L_0_INFECTIOUS.txt"))
#   writeRasterTxt(x = new_S, fileName = paste0(outDir, "L_0_SUSCEPTIBLE.txt"))
  
  
# }



