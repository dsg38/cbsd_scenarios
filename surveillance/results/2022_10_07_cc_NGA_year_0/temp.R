x = list.files("./data/simple_clusters/", "*.gpkg", full.names = TRUE)

stackdDfList = list()
for(thisPath in x){
    stackdDfList[[thisPath]] = sf::read_sf(thisPath)    
}

y = dplyr::bind_rows(stackdDfList)

max(y$prop)
