# Specify num inf fields
numFields = 5

# Radius around coordinate
kmRadius = 50

# Read in input files
hostRasterPath = "../../host_landscape/CassavaMap-cassava_data-2022_02_09/host.tif"

directIntroCoordsDf = read.csv("./direct_intro_coords.csv") |>
    sf::st_as_sf(coords=c('x', 'y'), crs="WGS84")

# ----------------------

hostRaster = raster::raster(hostRasterPath)

# For each CBSD-free WAVE country, create an introduction site at a major port 
for(iRow in seq_len(nrow(directIntroCoordsDf))){

    # Pull out target coords
    directIntroCoordsRow = directIntroCoordsDf[iRow,]

    print(directIntroCoordsRow$name)

    outDir = file.path("../", paste0("direct_intro_", directIntroCoordsRow$name))
    dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

    # Create empty inf raster at same extent as host
    infRaster = hostRaster
    infRaster[] = 0

    # Define circular polygon around coord where infected field(s) can be located
    nearPortPolyDf = sf::st_buffer(directIntroCoordsRow, dist=(kmRadius * 1000))

    # Extract this small circle of host landscape raster where new field(s) are allowed
    nearHostRaster = raster::crop(x=hostRaster, y=nearPortPolyDf) |>
        raster::mask(nearPortPolyDf, updatevalue=0)

    # Convert this small chunk of host to an x/y/host_val dataframe and drop areas of zero host
    nearHostPointsDf = as.data.frame(raster::rasterToPoints(nearHostRaster)) |>
        dplyr::filter(host > 0)

    # TEST: Check there's enough locations to put fields
    stopifnot(nrow(nearHostPointsDf) >= numFields)

    # Sample numFields locations to place inf fields
    randomRow = sample(x = seq_len(nrow(nearHostPointsDf)), size = numFields, replace = FALSE, prob = nearHostPointsDf$host)
    randomX = nearHostPointsDf[randomRow, 1]
    randomY = nearHostPointsDf[randomRow, 2]

    randomCoordsDf = data.frame(x=randomX, y=randomY)

    # Get corresponding 
    randomCellIndex = raster::cellFromXY(infRaster, xy = randomCoordsDf)

    # Calculate the number of fields in the host raster in each cell
    hostRasterCropNumFields = ceiling(1000 * hostRaster)
    numFieldsAtCellIndexes = hostRasterCropNumFields[randomCellIndex]

    # Calculate the proportion that would be equiv to one field given the num fields in the host raster
    propThatIsOneFieldVec = 1 / numFieldsAtCellIndexes

    # Drop this proportion into the inf raster
    infRaster[randomCellIndex] = propThatIsOneFieldVec

    #Create corresponding S and R rasters
    susRaster = 1 - infRaster

    remRaster = hostRaster
    remRaster[] = 0

    # Save as tifs
    raster::writeRaster(infRaster, file.path(outDir, "infRaster.tif"))
    raster::writeRaster(susRaster, file.path(outDir, "susRaster.tif"))
    raster::writeRaster(remRaster, file.path(outDir, "remRaster.tif"))

    # ----
    # Save diagnostics
    diagnosticDir = file.path(outDir, 'diagnostics')
    dir.create(diagnosticDir, showWarnings = FALSE, recursive = TRUE)
    
    randomCoordsDfSpatial = sf::st_as_sf(randomCoordsDf, coords=c('x', 'y'), crs="WGS84")

    p = mapview::mapview(nearPortPolyDf, col.regions='green', alpha.regions=0.05)+
        mapview::mapview(nearHostRaster, alpha.regions=0.4) + 
        mapview::mapview(randomCoordsDfSpatial, col.regions='red')

    mapview::mapshot(x=p, url=file.path(diagnosticDir, 'map.html'))

    diagnosticDf = cbind(
        randomCoordsDf,
        hostVals=hostRaster[randomCellIndex],
        numFieldsAtCellIndexes=numFieldsAtCellIndexes,
        propThatIsOneFieldVec=propThatIsOneFieldVec,
        randomCellIndex=randomCellIndex,
        name=directIntroCoordsRow$name
    )

    write.csv(diagnosticDf, file.path(diagnosticDir, "diagnosticDf.csv"), row.names = FALSE)

}
