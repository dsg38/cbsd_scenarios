box::use(dplyr[`%>%`])
box::use(ggplot2[...])
box::use(utils_epidem/utils_epidem)

batch = '2021_03_29_batch_0'
job = 'job133'

mapping_df = read.csv("./outputs/2021_03_26_cross_continental/survey_locations/host_real/survey_real/survey_scheme.csv")
survey_df = readRDS("./outputs/2021_03_26_cross_continental/results/big.rds")

host_stats_df = read.csv("./outputs/2021_03_26_cross_continental/host/host_real/stats_host_num_fields.csv")

# -----------------------------------------

survey_df_subset = survey_df[survey_df$batch==batch & survey_df$job==job,] %>%
    dplyr::left_join(mapping_df, by=c("raster_index")) %>%
    dplyr::mutate(cbsd_bool=num_positive_surveys>0)

raster_year_df = unique(survey_df_subset[,c("inf_raster_name", "raster_year_zero_index")])

out_list = list()
for(i_row in seq_len(nrow(raster_year_df))){
    
    print(i_row)
    
    this_row = raster_year_df[i_row,]
    
    raster_path = file.path("./outputs/2021_03_26_cross_continental/rasters_num_fields/", this_row$inf_raster_name)
    
    raster_layer = raster::raster(raster_path)
    
    inf_raster_sum = raster::cellStats(raster_layer, stat='sum', asSample=FALSE)
    
    out_row = data.frame(
        inf_raster_sum=inf_raster_sum,
        host_raster_sum=host_stats_df$num_fields,
        inf_prop=inf_raster_sum/host_stats_df$num_fields
    )
    
    out_list[[as.character(i_row)]] = out_row
}

stats_cols = dplyr::bind_rows(out_list)

stats_df = dplyr::bind_cols(raster_year_df, stats_cols)

for(i_row in seq_len(nrow(stats_df))){
    
    print(i_row)

    this_row = stats_df[i_row,]
    
    # Plot stats
    p = ggplot(stats_df, aes(x=raster_year_zero_index, y=inf_prop)) + 
        geom_line(col="red") +
        geom_point(data=this_row, aes(x=raster_year_zero_index, y=inf_prop), shape=4, size=3, stroke=3) +
        xlab("Year") + 
        ylab("Proportion of fields infected") +
        ylim(0, 1)
    
    plot_name = paste0(tools::file_path_sans_ext(this_row$inf_raster_name), ".png")
    out_path = file.path("./outputs/2021_03_26_cross_continental/plots/inf_prop/", plot_name)
    ggsave(plot=p, filename=out_path)
    
}
