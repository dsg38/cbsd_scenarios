#' @export
calcGridPassCriteria = function(
    thisSimKey,
    thisGrid,
    resultsDfSubset,
    surveyStatsDfSubset,
    maxFittingSurveyDataYear
){

    box::use(utils[...])
    
    # For this sim / grid cell, what score does it get?
    numSurveys = nrow(resultsDfSubset)
    
    surveyFirstInfYear = surveyStatsDfSubset$firstInfYear
    if(!is.na(surveyFirstInfYear) & (surveyFirstInfYear > maxFittingSurveyDataYear)){
        surveyFirstInfYear = NA
    }
    
    # Which years have any infection
    simAnyInfYears = resultsDfSubset[resultsDfSubset$infProp > 0, "surveyDataYear"]
    
    # If there are years with inf, what's the earlist
    simFirstInfYear = NA
    if(length(simAnyInfYears) > 0){
        simFirstInfYear = min(simAnyInfYears)
    }
    
    # Extract key info 
    gridDataCat = surveyStatsDfSubset$neighbouring_data_cat
    surveyFirstInfFinalYearBool = surveyFirstInfYear == maxFittingSurveyDataYear
    
    # Set up criteria
    exact_match_bool = FALSE
    tol_applied_only_where_both_bool = FALSE
    tol_applied_all_except_final_bool = FALSE
    tol_applied_all_bool = FALSE
    
    # Special handling of NA case
    
    # CAT_3 + CAT_4: If the survey inf year is NA (i.e. quadrat should never be infected)
    if(is.na(surveyFirstInfYear)){
        
        # CAT_3: Approve if sim also stays NA - this passes all criteria
        if(is.na(simFirstInfYear)){
            exact_match_bool = TRUE
            tol_applied_only_where_both_bool = TRUE
            tol_applied_all_except_final_bool = TRUE
            tol_applied_all_bool = TRUE
        }else{
            # CAT_4: If simFirstInfYear is defined, but target was NA (staying negative)
            # Leave all FALSE
        }
        
        
    }else if(is.na(simFirstInfYear)){
        # CAT_5: If survey is defined, but sim is NA
        # Leave all FALSE
    }else{
        
        # CAT_0 + CAT_1 + CAT_2: If both sim + survey first inf years are defined

        absDiffYears = abs(surveyFirstInfYear - simFirstInfYear)
        
        if(absDiffYears == 0){
            
            # If years match exactly, set all criteria to true
            exact_match_bool = TRUE
            tol_applied_only_where_both_bool = TRUE
            tol_applied_all_except_final_bool = TRUE
            tol_applied_all_bool = TRUE
            
        }else if(absDiffYears==1){
            
            # If one year tol either side
            
            if(gridDataCat == 'both'){
                
                # If grid is 'both', set 3 to true ('both' by definition cannot be final year)
                tol_applied_only_where_both_bool = TRUE
                tol_applied_all_except_final_bool = TRUE
                tol_applied_all_bool = TRUE
                
            }else if(gridDataCat == 'one' & surveyFirstInfFinalYearBool == FALSE){
                
                # If this grid only has one neighbouring survey, as long as the surveyFirstInfYear is not the final fitting year (2010), pass
                tol_applied_all_except_final_bool = TRUE
                tol_applied_all_bool = TRUE
                
            }else if(gridDataCat == 'one' & surveyFirstInfFinalYearBool == TRUE){
                
                # If this grid only has one neighbouring survey, even if it's the final year, pass
                tol_applied_all_bool = TRUE
                
            }
            
        }
        
    }
    
    outRow = data.frame(
        simKey=thisSimKey,
        polySuffix=thisGrid,
        surveyFirstInfYear=surveyFirstInfYear,
        simFirstInfYear=simFirstInfYear,
        gridDataCat=gridDataCat,
        exact_match_bool=exact_match_bool,
        tol_applied_only_where_both_bool=tol_applied_only_where_both_bool,
        tol_applied_all_except_final_bool=tol_applied_all_except_final_bool,
        tol_applied_all_bool=tol_applied_all_bool
    )
    
    return(outRow)
}

#' @export
calcGridPassCriteriaWrapper = function(
    resultsDfTargetPath,
    surveyStatsDfPath,
    maxFittingSurveyDataYear,
    gridDfOutPath
){

    box::use(utils[...])

    resultsDfTarget = readRDS(resultsDfTargetPath)
    
    # Extract subset of polys that contain any survey points within the fitting period
    surveyStatsDf = read.csv(surveyStatsDfPath) |>
        dplyr::filter(firstSurveyYear<=maxFittingSurveyDataYear)

    # Extract target grid polySuffix - based on the full set of survey stats
    polySuffixGrid = stringr::str_sort(stringr::str_subset(surveyStatsDf$polySuffix, "grid"), numeric=TRUE)

    # Extract unique simKeys
    simKeys = sort(unique(resultsDfTarget$simKey))

    # -----------

    rowList = list()
    for(thisSimKey in simKeys){
        
        print(thisSimKey)
        
        for(thisGrid in polySuffixGrid){
            
            resultsDfSubset = resultsDfTarget[resultsDfTarget$simKey==thisSimKey & resultsDfTarget$polySuffix==thisGrid,]
            surveyStatsDfSubset = surveyStatsDf[surveyStatsDf$polySuffix==thisGrid,]
            
            thisRow = calcGridPassCriteria(
                thisSimKey=thisSimKey,
                thisGrid=thisGrid,
                resultsDfSubset=resultsDfSubset,
                surveyStatsDfSubset=surveyStatsDfSubset,
                maxFittingSurveyDataYear=maxFittingSurveyDataYear
            )
            
            rowList[[paste0(thisSimKey, "_", thisGrid)]] = thisRow
            
        }
        
    }

    gridDf = dplyr::bind_rows(rowList)

    saveRDS(gridDf, gridDfOutPath)

}

#' @export
criteriaCols = c(
    "exact_match_bool",
    "tol_applied_only_where_both_bool",
    "tol_applied_all_except_final_bool",
    "tol_applied_all_bool"
)

#' @export
calcPerSimGridResults = function(
    gridDfPath,
    gridSimDfOutPath
){

    box::use(utils[...])

    gridDf = readRDS(gridDfPath)

    simKeys = unique(gridDf$simKey)

    gridSimRowList = list()
    # For each simulation
    for(thisSimKey in simKeys){
        
        print(thisSimKey)
        
        # Extract the subset of grids / criteria for this sim
        thisGridDf = gridDf[gridDf$simKey==thisSimKey,]
        
        numGrids = nrow(thisGridDf)
        
        # Check that all 19 grid cells are present
        stopifnot(numGrids==19)
        
        # Across all grids for this sim, what proportion pass each of the criteria
        for(thisCriteriaCol in criteriaCols){
            
            thisCriteriaBool = thisGridDf[[thisCriteriaCol]]
            propPass = sum(thisCriteriaBool) / numGrids
            propFail = 1 - propPass
            
            thisRow = data.frame(
                simKey=thisSimKey,
                criteria=thisCriteriaCol,
                propPass=propPass,
                propFail=propFail
            )
            
            gridSimRowList[[paste0(thisSimKey, "_", thisCriteriaCol)]] = thisRow
            
        }
        
    }

    gridSimDf = dplyr::bind_rows(gridSimRowList)

    saveRDS(gridSimDf, gridSimDfOutPath)

}
