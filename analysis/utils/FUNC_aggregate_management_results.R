options(stringsAsFactors = F)
library(dplyr)

extractManagementDf = function(thisManagementDf, thisManagementPath, thisBatch, thisJob){
  
  thisDir = dirname(thisManagementPath)
  thisManagementFilename = basename(thisManagementPath)
  
  splitFilename = strsplit(thisManagementFilename, "_")[[1]]
  
  thisSimYearStr = splitFilename[6]
  thisSimYear = as.numeric(gsub(".txt", "", thisSimYearStr))
  
  thisJobSim = as.numeric(splitFilename[2])
    
  thisManagementDfOut = cbind(
    batch=thisBatch,
    job=thisJob,
    jobSim=thisJobSim,
    simYear=thisSimYear,
    thisManagementDf
  )
  
  # Gen params
  paramsDfPath = file.path(thisDir, paste0("O_", thisJobSim, "_ParameterDistribution_0_Log.txt"))
  paramsDf = read.csv(paramsDfPath, sep="")
  
  thisManagementDfOut = cbind(thisManagementDfOut, paramsDf)
  
  return(thisManagementDfOut)
  
}

aggregateManagementResults = function(simDir, stackedOutPath){
  
  dir.create(dirname(stackedOutPath), showWarnings = F, recursive = T)

  jobDirs = list.files(simDir, "job*", full.names = T)

  thisBatch = basename(simDir)

  stackedManagementList = list()

  jobCount = 0
  numJobs = length(jobDirs)
  for(thisJobDir in jobDirs){
    
    print(paste0("Progress: ", jobCount/numJobs * 100, "%"))
    
    thisJob = basename(thisJobDir)
    print(thisJobDir)    
    managementPaths = list.files(thisJobDir, pattern="O_.*_Management_SurveyResults_Time_.*.000000.txt", full.names = T, recursive = T)
    
    for(thisManagementPath in managementPaths){
      
      thisFilesize = file.size(thisManagementPath)
      if(!is.na(thisFilesize)){
        if(thisFilesize>0){

          thisManagementDf = read.csv(thisManagementPath, sep="\t")

          if(nrow(thisManagementDf)>0){

            thisManagementDfOut = extractManagementDf(
              thisManagementDf=thisManagementDf,
              thisManagementPath=thisManagementPath,
              thisBatch=thisBatch,
              thisJob=thisJob
            )
            stackedManagementList[[thisManagementPath]] = thisManagementDfOut

          }
        }
      }
      else{
        print(thisManagementPath)
      }
      
    }
    
    jobCount = jobCount + 1
    
  }

  stackedManagementDf = bind_rows(stackedManagementList)

  dir.create(dirname(stackedOutPath), showWarnings = FALSE, recursive = TRUE)

  saveRDS(stackedManagementDf, stackedOutPath)

}

