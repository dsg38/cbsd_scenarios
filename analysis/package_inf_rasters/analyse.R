statsDfPath = "../../simulations/sim_output/2021_03_26_cross_continental/2021_03_29_batch_0/raster_poly_stats_agg.rds"
outPath = "../../simulations/sim_output/2021_03_26_cross_continental/2021_03_29_batch_0/raster_poly_stats_agg_minimal.rds"

# --------------------------------------

statsDf = readRDS(statsDfPath)

keepCols = c(
    "POLY_ID",
    "raster_num_fields",
    "raster_num_cells_populated",
    "raster_prop_fields",
    "raster_year",
    "raster_type",
    "job",
    "batch",
    "scenario"
)

x = statsDf[,keepCols]

print(object.size(statsDf))
print(object.size(x))

saveRDS(x, outPath)

# statsDfPath = "../../simulations/sim_output/2021_03_26_cross_continental/2021_03_29_batch_0/raster_poly_stats_agg.rds"

# ----------------------------------------

# statsDf = readRDS(statsDfPath)
# 
# x = object.size(statsDf)
# 
# print(x)
# 
# statsDfSmall = statsDf[1:10000,]
# 
# saveRDS(statsDfSmall, "stuff.rds")


# 
# # Work out average nigeria arrival time
# 
# statsDfCode = statsDf[statsDf$POLY_ID=="mask_drc_nw",]
# 
# x = statsDfCode[statsDfCode$raster_year==2017,]
# sum(x$raster_num_fields>0)
# 
# length(unique(statsDf$job))
