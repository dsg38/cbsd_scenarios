box::use(../../../utils_analysis)
# box::reload(utils_analysis)

surveyKeysList = rjson::fromJSON(file="./output/results_sim_survey.json")
infKeysList = rjson::fromJSON(file="./output/results_inf_polys.json")

# names(surveyKeysList)

# Parse NGA arrival times
polysDf = readRDS("./output/raster_poly_stats_agg_minimal.rds")

polysDfNgaRaw = polysDf[polysDf$POLY_ID=="NGA",]

simKeys = paste(polysDfNgaRaw$scenario, polysDfNgaRaw$batch, polysDfNgaRaw$job, "0", sep="-")

polysDfNga = cbind(polysDfNgaRaw, simKey=simKeys)

# --------------------------------------------------------------------------------------
# Plot all
utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="unconstrained"
)

# Uga
surveyUgaKeys = intersect(surveyKeysList[["mask_uga_hole"]], surveyKeysList[["mask_uga_kam"]])

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga",
    matchKeys=surveyUgaKeys
)


# Inf DRC central small
# ugaDrcCenSmallKeys = intersect(surveyUgaKeys, infKeysList[["2018-mask_drc_central_small"]])

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_drc-central-small-2017",
    matchKeys=intersect(surveyUgaKeys, infKeysList[["2017-mask_drc_central_small"]])
)

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_drc-central-small-2018",
    matchKeys=intersect(surveyUgaKeys, infKeysList[["2018-mask_drc_central_small"]])
)


utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_rwa-2009",
    matchKeys=intersect(surveyUgaKeys, infKeysList[["2009-RWA"]])
)


utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_rwa-2010",
    matchKeys=intersect(surveyUgaKeys, infKeysList[["2010-RWA"]])
)

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_bdi-2011",
    matchKeys=intersect(surveyUgaKeys, infKeysList[["2011-BDI"]])
)

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_bdi-2012",
    matchKeys=intersect(surveyUgaKeys, infKeysList[["2012-BDI"]])
)

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_drc-2016",
    matchKeys=intersect(surveyUgaKeys, infKeysList[["2016-COD.3_1"]])
)

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_drc-2017",
    matchKeys=intersect(surveyUgaKeys, infKeysList[["2017-COD.3_1"]])
)

# Zam either
zamInfEither2017 = union(infKeysList[["2017-ZMB.4_1"]], infKeysList[["2017-ZMB.8_1"]])

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_zam-2017",
    matchKeys=intersect(surveyUgaKeys, zamInfEither2017)
)

zamInfEither2018 = union(infKeysList[["2018-ZMB.4_1"]], infKeysList[["2018-ZMB.8_1"]])

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="survey_uga_inf_zam-2018",
    matchKeys=intersect(surveyUgaKeys, zamInfEither2018)
)


# All
earlyList = list(
    surveyUgaKeys,
    infKeysList[["2017-mask_drc_central_small"]],
    infKeysList[["2009-RWA"]],
    infKeysList[["2011-BDI"]],
    infKeysList[["2016-COD.3_1"]],
    zamInfEither2017    
)

allEarly = Reduce(intersect, earlyList)

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="all-early",
    matchKeys=allEarly
)

lateList = list(
    surveyUgaKeys,
    infKeysList[["2018-mask_drc_central_small"]],
    infKeysList[["2010-RWA"]],
    infKeysList[["2012-BDI"]],
    infKeysList[["2017-COD.3_1"]],
    zamInfEither2018
)

allLate = Reduce(intersect, lateList)

utils_analysis$getArrivalVec(
    polysDfNga=polysDfNga,
    title="all-late",
    matchKeys=allLate
)
# 
# # Survey drc central small
# ugaSurveyDrcCenSmallKeys = intersect(surveyUgaKeys, surveyKeysList[["2017_mask_drc_central_small"]])
# 
# utils_analysis$getArrivalVec(
#     polysDfNga=polysDfNga,
#     title="survey_uga_survey_drc-central-small",
#     matchKeys=ugaSurveyDrcCenSmallKeys
# )
# 
# # Uga + inf NW (inf = +1 year as instantaneous at end)
# infDrcNwKeys = union(infKeysList[["2018-COD.23_1"]], infKeysList[["2018-COD.20_1"]])
# 
# utils_analysis$getArrivalVec(
#     polysDfNga=polysDfNga,
#     title="inf_drc-nw",
#     matchKeys=infDrcNwKeys
# )
# 
# ugaDrcNwKeys = intersect(surveyUgaKeys, infDrcNwKeys)
# 
# utils_analysis$getArrivalVec(
#     polysDfNga=polysDfNga,
#     title="survey_uga_inf_drc-nw",
#     matchKeys=ugaDrcNwKeys
# )
# 
# # Get for either COD regions
# surveyUgaSurveyDrc = intersect(surveyUgaKeys, surveyKeysList[["2016_COD.3_1"]])
# 
# utils_analysis$getArrivalVec(
#     polysDfNga=polysDfNga,
#     title="survey_uga_survey_drc_2016",
#     matchKeys=surveyUgaSurveyDrc
# )
# 
# # ZBA 2017
# surveyZba2017 = union(surveyKeysList[["2017_ZMB.4_1"]], surveyKeysList[["2017_ZMB.8_1"]])
# surveyUgaSurveyZba2017 = intersect(surveyUgaKeys, surveyZba2017)
# 
# utils_analysis$getArrivalVec(
#     polysDfNga=polysDfNga,
#     title="survey_uga_survey_zba_2017",
#     matchKeys=surveyUgaSurveyZba2017
# )
# 
# # ZBA 2018
# surveyZba2018 = union(surveyKeysList[["2018_ZMB.4_1"]], surveyKeysList[["2018_ZMB.8_1"]])
# surveyUgaSurveyZba2018 = intersect(surveyUgaKeys, surveyZba2018)
# 
# utils_analysis$getArrivalVec(
#     polysDfNga=polysDfNga,
#     title="survey_uga_survey_zba_2018",
#     matchKeys=surveyUgaSurveyZba2018
# )



