box::use(dplyr[`%>%`])
box::use(ggplot2[...])
box::use(utils_epidem/utils_epidem)

batch = "2021_03_29_batch_0"
job = "job200"

mapping_df = read.csv("./outputs/2021_03_26_cross_continental/survey_locations/host_real/survey_real/survey_scheme.csv")
survey_df = readRDS("./outputs/2021_03_26_cross_continental/results/big.rds")
# -----------------------------------------

survey_df_subset = survey_df[survey_df$batch==batch & survey_df$job==job,] %>%
    dplyr::left_join(mapping_df, by=c("raster_index")) %>%
    dplyr::mutate(cbsd_bool=num_positive_surveys>0)

survey_sf = sf::st_as_sf(survey_df_subset, coords=c("longitude", "latitude"), crs="WGS84")

# Split by year and plot
survey_sf_split = split(survey_sf, survey_sf$year)

# Gen plot constants
africa_polys_df = utils_epidem$getAfricaPolys()
extentData = sf::st_bbox(africa_polys_df[africa_polys_df$GID_0=="NGA",])
cropX = c(extentData$xmin, extentData$xmax)
cropY = c(extentData$ymin, extentData$ymax)
cols = c("FALSE"="green", "TRUE"="red")

# -------------------------------------------------------------

for(year in names(survey_sf_split)){
    
    print(year)
    
    df = survey_sf_split[[year]]
    
    # -----------------------------
    
    # Plot title stats
    num_surveys_pos = sum(df$num_positive_surveys)
    num_surveys = sum(df$num_surveys)
    
    # Plot
    p = ggplot() +
        geom_sf(data=africa_polys_df) +
        geom_sf(data=df, pch=3, stroke=1, size=2, aes(col=cbsd_bool)) +
        scale_colour_manual(values=cols) +
        coord_sf(xlim=cropX, ylim=cropY) +
        ggtitle(paste0("Year: ", year, ", nSurveys: ", num_surveys, ", nPos: ", num_surveys_pos)) +
        theme(legend.position = "none")
    
    # Save plot
    out_path = file.path("./outputs//2021_03_26_cross_continental/plots/", paste0(batch, "-", job, "-", year, ".png"))
    ggsave(filename=out_path, plot=p)
}

