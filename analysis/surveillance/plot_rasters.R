box::use(dplyr[`%>%`])
box::use(utils_epidem/utils_epidem)
box::use(tmap[...])

batch = '2021_03_29_batch_0'
job = 'job133'

mapping_df = read.csv("./outputs/2021_03_26_cross_continental/survey_locations/host_real/survey_real/survey_scheme.csv")
survey_df = readRDS("./outputs/2021_03_26_cross_continental/results/big.rds")

# ---------------------------------------

survey_df_subset = survey_df[survey_df$batch==batch & survey_df$job==job,] %>%
    dplyr::left_join(mapping_df, by=c("raster_index")) %>%
    dplyr::mutate(cbsd_bool=num_positive_surveys>0)

survey_df_split = split(survey_df_subset, survey_df_subset$year)

# df = survey_df_split[[1]]

# Read in rasters
plot_raster = function(
    raster_path,
    out_path
    ){

    propRaster = raster::raster(raster_path)

    propRaster[propRaster==0] = NA

    africa_polys_df = utils_epidem$getAfricaPolys()
    extent_bbox = sf::st_bbox(africa_polys_df[africa_polys_df$GID_0=="NGA",])

    p = tm_shape(propRaster, bbox=extent_bbox) + 
        tm_raster(
            title = "Number of CBSD\ninfected fields",
            palette="Reds"
        ) + 
        tm_shape(africa_polys_df) +
        tm_borders() + 
        tm_layout(legend.outside = TRUE, legend.outside.size=0.15)
    
    tmap_save(p, out_path)

}

for(year in names(survey_df_split)){

    print(year)
    
    df = survey_df_split[[year]]
    
    raster_name = df$inf_raster_name[[1]]
    fig_name = paste0(tools::file_path_sans_ext(raster_name), ".png")
    
    raster_path = file.path("./outputs//2021_03_26_cross_continental/rasters_num_fields/", df$inf_raster_name[[1]])
    out_path = file.path("./outputs/2021_03_26_cross_continental/plots/inf_rasters/", fig_name)
    
    plot_raster(
        raster_path=raster_path,
        out_path=out_path
    )
    
}
