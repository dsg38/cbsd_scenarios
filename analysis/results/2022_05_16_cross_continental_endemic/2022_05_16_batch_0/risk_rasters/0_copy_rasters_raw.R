args = commandArgs(trailingOnly=TRUE)

simDir = "../../../../../simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/"

rasterYear = args[[1]]
numJobs = as.numeric(args[[2]])

# rasterYear = 2023
# numJobs = 10000

# Def out dir
outDir = file.path("./raw/", paste0("inf_rasters_", rasterYear))
dir.create(outDir, recursive = TRUE, showWarnings = FALSE)

print("Copying")
for(i in seq(0, numJobs-1)){

    job = paste0("job", i)
    
    rasterPath = file.path(simDir, job, "output/runfolder0/", paste0("O_0_L_0_INFECTIOUS_", rasterYear, ".000000.tif"))
    
    if(file.exists(rasterPath)){
        
        print(job)
        
        outPath = file.path(outDir, paste0(job, "-", basename(rasterPath)))
        
        file.copy(from=rasterPath, to=outPath, overwrite = TRUE)
    }


}
