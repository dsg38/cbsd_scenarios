managementDfPaths = list.files("./output", "management_stacked_.*.rds", full.names = TRUE)

stackedDfList = list()
for(i in managementDfPaths){
    stackedDfList[[i]] = readRDS(i)
}

x = dplyr::bind_rows(stackedDfList)

saveRDS(x, "./output/management_stacked.rds")
