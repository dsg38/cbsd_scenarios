#' @export
gen_ceil_raster = function(raster_path){

    raster_layer_raw = raster::raster(raster_path)

    raster_layer = ceiling(round(raster_layer_raw, 2))

    return(raster_layer)
}

#' @export
do_full_survey = function(
    inf_raster_path,
    host_raster,
    raster_survey_df
){

    inf_raster = gen_ceil_raster(inf_raster_path)

    do_raster_cell_survey = function(
        inf_raster_name,
        num_surveys,
        raster_index,
        inf_raster,
        host_raster
    ){
        
        inf_raster_val = inf_raster[raster_index]
        if(!is.numeric(inf_raster_val)){
            inf_raster_val = 0
        }
        
        host_raster_val = host_raster[raster_index]
        
        num_neg = host_raster_val - inf_raster_val

        # Random sample from hypergeometric distribution
        # nn = num replicates = 1
        # m = POS
        # n = NEG
        # k = num surveys in cell
        # Returns num positive samples
        num_positive_surveys = stats::rhyper(
            nn=1,
            m=inf_raster_val,
            n=num_neg,
            k=num_surveys
        )
        
        survey_result_row = data.frame(
            inf_raster_name=inf_raster_name,
            raster_index=raster_index,
            num_fields_ceil=host_raster_val,
            num_infected_fields_ceil=inf_raster_val,
            num_surveys=num_surveys,
            num_positive_surveys=num_positive_surveys
        )
        
    }

    inf_raster_name = basename(inf_raster_path)

    survey_results_list = list()
    for(i_row in seq_len(nrow(raster_survey_df))){

        this_row = raster_survey_df[i_row,]
        
        survey_result_row = do_raster_cell_survey(
            inf_raster_name=inf_raster_name,
            num_surveys=this_row$num_surveys_in_cell,
            raster_index=this_row$cells,
            inf_raster=inf_raster,
            host_raster=host_raster
        )
        
        survey_results_list[[as.character(i_row)]] = survey_result_row

    }

    survey_results_df = dplyr::bind_rows(survey_results_list)

    return(survey_results_df)
}
