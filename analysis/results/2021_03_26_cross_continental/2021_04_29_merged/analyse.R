surveyKeysList = rjson::fromJSON(file="./output/results_sim_survey.json")
infKeysList = rjson::fromJSON(file="./output/results_inf_polys.json")

names(surveyKeysList)
names(infKeysList)

surveyUgaKeys = intersect(surveyKeysList[["mask_uga_hole"]], surveyKeysList[["mask_uga_kam"]])

surveyDrcNwKeys = surveyKeysList[["2017_mask_drc_nw"]]
# y = intersect(surveyUgaKeys, surveyDrcNwKeys)

# Uga + inf NW
infDrcNwKeys = union(infKeysList[["2018-COD.23_1"]], infKeysList[["2018-COD.20_1"]])

x = intersect(surveyUgaKeys, infDrcNwKeys)
