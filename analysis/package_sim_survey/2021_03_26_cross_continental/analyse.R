box::use(../utils_analysis)
# box::reload(utils_analysis)

resultsDfPath = "../../results/2021_03_26_cross_continental/2021_04_29_merged/output/management_results.rds"
resultsDf = readRDS(resultsDfPath)
# ------------------------------------------------------------------

tol = 0.3

# Get keys for each constraint

# Uga hole - pass all years with tol
passKeysUgaHole = utils_analysis$applyAllPolySuffix(
    resultsDf = resultsDf,
    polySuffix = "mask_uga_hole",
    tol = tol
)


# Uga kam - pass all years with tol
passKeysUgaKam = utils_analysis$applyAllPolySuffix(
    resultsDf = resultsDf,
    polySuffix = "mask_uga_kam",
    tol = tol
)

length(unique(resultsDf$simKey))

passKeysUga = intersect(passKeysUgaHole, passKeysUgaKam)

# Any in each DRC poly in 2017
drcPolyNameVec = c(
    "2017_mask_drc_central_small",
    "2017_mask_drc_central_big",
    "2017_mask_drc_nw",
    "2017_mask_drc_central_south"
)

drcList = list()
drcUgaList = list()
for(drcPolyName in drcPolyNameVec){

    # print(drcPolyName)

    passKeysDrc = utils_analysis$anyInfSpecificPoly(
        resultsDf = resultsDf,
        polyName = drcPolyName
    )

    drcList[[drcPolyName]] = passKeysDrc
    # print(length(passKeysDrc))

    passKeysDrcUga = intersect(passKeysDrc, passKeysUga)
    drcUgaList[[drcPolyName]] = passKeysDrcUga

    # print(length(passKeysDrcUga))
}

# ------------------------------------
# Plotting

resultsDfSubset = utils_analysis$subsetResultsDf(
    resultsDf = resultsDf,
    polySuffix = "mask_uga_hole",
    passKeys = passKeysUgaHole
)

p = utils_analysis$plotInfProp(
    resultsDf=resultsDfSubset,
    tol=0.3
)

print(p)

# --------

resultsDfSubset = utils_analysis$subsetResultsDf(
    resultsDf = resultsDf,
    polySuffix = "mask_uga_hole",
    passKeys = drcUgaList[['2017_mask_drc_central_small']]
)


p = utils_analysis$plotInfProp(
    resultsDf=resultsDfSubset,
    tol=0.3
)

print(p)
