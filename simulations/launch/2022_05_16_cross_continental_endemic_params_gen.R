x = data.frame(
    
    # Standard params
    SimulationStartTime="2004",
    SimulationLength="50",
    ManagementEnable="1",
    RasterEnable="1",
    RasterFrequency="1",
    RasterEnable_0_REMOVED="0",

    # ADD IN RATES FOR I TO R AND R TO S
    Rate_0_ItoR="0",
    Rate_0_RtoS="1000000000",

    # INTENAL DETECTION
    DetectionEnable="1",
    DetectionParameter="1.0",
    DetectionFrequency="1",
    DetectionFirst="2013.0",

    # CONTROL IMPLEMENTATION
    ControlCullEnable="1",
    ControlCullFrequency="1.0",
    ControlCullFirst="2013.01",
    ControlCullLast="2015.5",
    ControlCullControlMethodSpecification="RASTER",
    ControlCullControlMethodRasterName="control_raster.asc",
    ControlCullEffectiveness="0.15"

)

write.table(x, "./2022_05_16_cross_continental_endemic_params.txt", quote=FALSE, row.names = FALSE)
