surveyKeysList = rjson::fromJSON(file="./output/results_sim_survey.json")
infKeysList = rjson::fromJSON(file="./output/results_inf_polys.json")

# Parse NGA arrival times
polysDf = readRDS("./output/raster_poly_stats_agg_minimal.rds")

jsonOutPath = "./output/constraint_sim_keys.json"

# ---------------------------------------------------------------

polysDfNgaRaw = polysDf[polysDf$POLY_ID=="NGA",]

simKeys = paste(polysDfNgaRaw$scenario, polysDfNgaRaw$batch, polysDfNgaRaw$job, "0", sep="-")

# --------------------------------------

outList = list()
# Unconstrained
outList[["unconstrained"]] = unique(simKeys)

# Uga
surveyUgaKeys = intersect(surveyKeysList[["mask_uga_hole"]], surveyKeysList[["mask_uga_kam"]])

outList[["survey_uga"]] = surveyUgaKeys

# Inf DRC central small
# ugaDrcCenSmallKeys = intersect(surveyUgaKeys, infKeysList[["2018-mask_drc_central_small"]])

outList[["survey_uga_inf_drc-central-small-2017"]] = intersect(surveyUgaKeys, infKeysList[["2017-mask_drc_central_small"]])

outList[["survey_uga_inf_drc-central-small-2018"]] = intersect(surveyUgaKeys, infKeysList[["2018-mask_drc_central_small"]])

outList[["survey_uga_inf_rwa-2009"]] = intersect(surveyUgaKeys, infKeysList[["2009-RWA"]])

outList[["survey_uga_inf_rwa-2010"]] = intersect(surveyUgaKeys, infKeysList[["2010-RWA"]])

outList[["survey_uga_inf_bdi-2011"]] = intersect(surveyUgaKeys, infKeysList[["2011-BDI"]])

outList[["survey_uga_inf_bdi-2012"]] = intersect(surveyUgaKeys, infKeysList[["2012-BDI"]])

outList[["survey_uga_inf_drc-2016"]] = intersect(surveyUgaKeys, infKeysList[["2016-COD.3_1"]])

outList[["survey_uga_inf_drc-2017"]] = intersect(surveyUgaKeys, infKeysList[["2017-COD.3_1"]])


# Zam either
zamInfEither2017 = union(infKeysList[["2017-ZMB.4_1"]], infKeysList[["2017-ZMB.8_1"]])

outList[["survey_uga_inf_zam-2017"]] = intersect(surveyUgaKeys, zamInfEither2017)

zamInfEither2018 = union(infKeysList[["2018-ZMB.4_1"]], infKeysList[["2018-ZMB.8_1"]])

outList[["survey_uga_inf_zam-2018"]] = intersect(surveyUgaKeys, zamInfEither2018)

# All
earlyList = list(
    surveyUgaKeys,
    infKeysList[["2017-mask_drc_central_small"]],
    infKeysList[["2009-RWA"]],
    infKeysList[["2011-BDI"]],
    infKeysList[["2016-COD.3_1"]],
    zamInfEither2017    
)

outList[["all-early"]] = Reduce(intersect, earlyList)

lateList = list(
    surveyUgaKeys,
    infKeysList[["2018-mask_drc_central_small"]],
    infKeysList[["2010-RWA"]],
    infKeysList[["2012-BDI"]],
    infKeysList[["2017-COD.3_1"]],
    zamInfEither2018
)

outList[["all-late"]] = Reduce(intersect, lateList)

# ----------------------------------------------------

outListStr = rjson::toJSON(outList, indent = 4)

readr::write_file(outListStr, jsonOutPath)
