managementDfPaths = list.files("./output", "resultsDfSummary_.*.rds", full.names = TRUE)

stackedDfList = list()
for(i in managementDfPaths){
    stackedDfList[[i]] = readRDS(i)
}

x = dplyr::bind_rows(stackedDfList)

saveRDS(x, "./output/resultsDfSummary.rds")
