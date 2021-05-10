# length(unique(resultsDf$simKey))

# passKeysUga = intersect(passKeysUgaHole, passKeysUgaKam)

    # print(length(passKeysDrc))

    # passKeysDrcUga = intersect(passKeysDrc, passKeysUga)
    # drcUgaList[[drcPolyName]] = passKeysDrcUga

    # print(length(passKeysDrcUga))


# ------------------------------------
# Plotting
# 
# resultsDfSubset = utils_analysis$subsetResultsDf(
#     resultsDf = resultsDf,
#     polySuffix = "mask_uga_hole",
#     passKeys = passKeysUgaHole
# )
# 
# p = utils_analysis$plotInfProp(
#     resultsDf=resultsDfSubset,
#     tol=0.3
# )
# 
# print(p)
# 
# # --------
# 
# resultsDfSubset = utils_analysis$subsetResultsDf(
#     resultsDf = resultsDf,
#     polySuffix = "mask_uga_hole",
#     passKeys = drcUgaList[['2017_mask_drc_central_small']]
# )
# 
# 
# p = utils_analysis$plotInfProp(
#     resultsDf=resultsDfSubset,
#     tol=0.3
# )
# 
# print(p)
