jobIndexVec = seq(0, 9999)

paramsDfAllList = list()
for(jobIndex in jobIndexVec){
    
    job = paste0("job", jobIndex)
    
    simKey = paste0("2022_05_16_cross_continental_endemic-2022_05_16_batch_0-", job, "-0")
    
    paramsDfPath = file.path("../simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0", job,"output/runfolder0/O_0_ParameterDistribution_0_Log.txt")
    
    if(file.exists(paramsDfPath)){
        
        print(job)
        
        paramsDf = read.csv(paramsDfPath, sep="") |>
            dplyr::mutate(simKey=simKey, job=job)
        
        paramsDfAllList[[simKey]] = paramsDf
        
    }
    
}

paramsDfAll = dplyr::bind_rows(paramsDfAllList) |>
    dplyr::mutate(Rate_0_Sporulation_log = log(Rate_0_Sporulation))

write.csv(paramsDfAll, "./inputs/params.csv", row.names = FALSE)