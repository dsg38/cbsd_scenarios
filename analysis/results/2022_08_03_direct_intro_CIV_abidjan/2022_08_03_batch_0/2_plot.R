library(ggplot2)
library(ggfan)

polyStatsDf = readRDS("./output/raster_poly_stats_agg_minimal_DONE.rds") 

outDir = file.path("./plots/dpc_fan_intervals")

dir.create(outDir, showWarnings = FALSE, recursive = TRUE)

# p = ggplot(polyStatsDf, aes(x=raster_year, y=raster_prop_fields, col=job)) + 
#     geom_line() +
#     theme(legend.position="none")
# p

for(thisPolyId in sort(unique(polyStatsDf$POLY_ID))){
    
    outPath = file.path(outDir, paste0(thisPolyId, ".png"))
    print(outPath)
    
    polyStatsDfSubset = polyStatsDf |>
        dplyr::filter(POLY_ID==thisPolyId)
    
    p = ggplot(data=polyStatsDfSubset, aes(x=raster_year, y=raster_prop_fields)) +
        geom_fan(intervals = seq(0,1,0.2)) +
        # geom_fan() +
        scale_fill_gradient(low="#5D5DF8", high="#C1C1EF") +
        ylim(0,1)+
        xlab("Year") + 
        ylab("Proportion of fields with CBSD infection") +
        theme(
            legend.position = "none",
            axis.text=element_text(size=12),
            axis.title=element_text(size=12)
        )

    # p
    
    cowplot::save_plot(outPath, plot=p, base_asp = 1)
    
}

