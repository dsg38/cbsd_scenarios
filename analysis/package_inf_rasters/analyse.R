statsDfPath = "../../simulations/sim_output/2021_03_26_cross_continental/2021_03_29_batch_0/raster_poly_stats_agg.rds"

# ----------------------------------------

statsDf = readRDS(statsDfPath)

x = object.size(statsDf)

print(x)

# 
# # Work out average nigeria arrival time
# 
# statsDfCode = statsDf[statsDf$POLY_ID=="mask_drc_nw",]
# 
# x = statsDfCode[statsDfCode$raster_year==2017,]
# sum(x$raster_num_fields>0)
# 
# length(unique(statsDf$job))
