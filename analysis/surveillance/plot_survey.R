box::use(dplyr[`%>%`])
box::use(ggplot2[...])
box::use(utils_epidem/utils_epidem)


# -----------------------------------------

plotSurvey = function(
    batch,
    job,
    num_positive_surveys_column,
    mapping_df,
    survey_df
){
    
    survey_df_subset = survey_df[survey_df$batch==batch & survey_df$job==job,] %>%
        dplyr::left_join(mapping_df, by=c("raster_index")) %>%
        dplyr::mutate(cbsd_bool = !!sym(num_positive_surveys_column) > 0)
    
    survey_sf = sf::st_as_sf(survey_df_subset, coords=c("longitude", "latitude"), crs="WGS84")
    
    # Split by year and plot
    survey_sf_split = split(survey_sf, survey_sf$raster_year_zero_index)
    
    # Gen plot constants
    africa_polys_df = utils_epidem$getAfricaPolys()
    extentData = sf::st_bbox(africa_polys_df[africa_polys_df$GID_0=="NGA",])
    cropX = c(extentData$xmin, extentData$xmax)
    cropY = c(extentData$ymin, extentData$ymax)
    cols = c("FALSE"="green", "TRUE"="red")
    
    # -------------------------------------------------------------

    out_dir = file.path("./outputs//2021_03_26_cross_continental/plots/", num_positive_surveys_column, "surveys")
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
    
    for(year in names(survey_sf_split)){
        
        print(year)
        
        df = survey_sf_split[[year]]
        
        # -----------------------------
        
        # Plot title stats
        num_surveys_pos = sum(df[[num_positive_surveys_column]])
        num_surveys = sum(df$num_surveys)
        
        # Plot
        p = ggplot() +
            geom_sf(data=africa_polys_df) +
            geom_sf(data=df, pch=3, stroke=1, size=2, aes(col=cbsd_bool)) +
            scale_colour_manual(values=cols) +
            coord_sf(xlim=cropX, ylim=cropY) +
            ggtitle(paste0("Year: ", year, ", nSurveys: ", num_surveys, ", nPos: ", num_surveys_pos)) +
            theme(legend.position = "none")
        
        raster_year = df$raster_year[[1]]
        
        # Save plot
        out_path = file.path(out_dir, paste0(batch, "-", job, "-INF-", raster_year, ".png"))
        ggsave(filename=out_path, plot=p)
    }
    
}

num_positive_surveys_column_vec = c(
    "num_positive_surveys_0_00",
    "num_positive_surveys_0_15",
    "num_positive_surveys_0_30"
)

mapping_df = read.csv("./outputs/2021_03_26_cross_continental/survey_locations/host_real/survey_real/survey_scheme.csv")
survey_df = readRDS("./outputs/2021_03_26_cross_continental/results/big.rds")

plot_subset_df = read.csv("./outputs/2021_03_26_cross_continental/plots/plot_subset.csv")

for(iRow in seq_len(nrow(plot_subset_df))){

    plot_df_row = plot_subset_df[iRow,]

    for(num_positive_surveys_column in num_positive_surveys_column_vec){

        plotSurvey(
            batch=plot_df_row$batch,
            job=plot_df_row$job,
            num_positive_surveys_column=num_positive_surveys_column,
            mapping_df=mapping_df,
            survey_df=survey_df
        )

    }

}
