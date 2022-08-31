# x = sf::read_sf("./inputs/inputs_raw/polygons/polys_direct_intro_host_CassavaMap.gpkg")

x = read.csv("../cassava_data/data_merged/data/2022_02_09/cassava_data_minimal.csv") |>
    dplyr::group_by(country_code, year) |>
    dplyr::count() |>
    dplyr::filter(country_code == "NGA")


# x = read.csv("./analysis/results/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/output/medianArrivalDf.csv")

# args = commandArgs(trailingOnly=TRUE)

# # configPath = args[[1]]

# # b = args[[2]]

# # c = args[[3]]

# progDf = read.csv("./simulations/sim_output/2022_05_16_cross_continental_endemic/2022_05_16_batch_0/progress.csv")

# x = progDf[1:10,]
# y = progDf[11:20,]

# a = c(1, 2, 3, 4, 5)

# a[1:5]
# 
# length(a)
