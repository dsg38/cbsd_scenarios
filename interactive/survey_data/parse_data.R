# Get new data
newDf = sf::read_sf("../../../cassava_data/data_merged/data/2021_10_01/cassava_data_minimal.gpkg")

file.copy(
    "../../../cassava_data/data_merged/data/2021_10_01/cassava_data_minimal.gpkg",
    "./data/2021_10_01-cassava_data_minimal.gpkg"
)

# Get old data

