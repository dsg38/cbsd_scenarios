simDir = "../../simulations/sim_output/2022_11_25_direct_intro_NGA_weighted/2022_11_25_batch_0/"

dpcDfPaths = list.files(simDir, pattern="O_0_DPCData.txt", recursive = TRUE, full.names = TRUE)

bigDfList = list()
for(dpcDfPath in dpcDfPaths){
    
    print(dpcDfPath)
    
    job = basename(dirname(dirname(dirname(dpcDfPath))))
    batch = basename(dirname(dirname(dirname(dirname(dpcDfPath)))))
    scenario = basename(dirname(dirname(dirname(dirname(dirname(dpcDfPath))))))
    
    dpcDf = read.table(dpcDfPath, header=TRUE) |>
        dplyr::mutate(job=job, batch=batch, scenario=scenario)
    
    bigDfList[[dpcDfPath]] = dpcDf
    
}

bigDf = dplyr::bind_rows(bigDfList)

outPath = "./data/bigDf.rds"

dir.create(dirname(outPath), showWarnings = FALSE, recursive = TRUE)

saveRDS(bigDf, outPath)
