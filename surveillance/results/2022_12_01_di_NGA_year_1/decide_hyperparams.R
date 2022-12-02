optimalDfA = read.csv("../2022_10_07_cc_NGA_year_0/data/optimalDf.csv") |>
    dplyr::mutate(cat="A")


optimalDfB = read.csv("../2022_10_07_cc_NGA_year_1/data/optimalDf.csv") |>
    dplyr::mutate(cat="B")


optimalDf = dplyr::bind_rows(optimalDfA, optimalDfB)

x = optimalDf |>
    dplyr::group_by(step) |>
    dplyr::count()

y = optimalDf |>
    dplyr::group_by(initTemp) |>
    dplyr::count()

# dplyr::count(optimalDf$step)
# optimalDf$