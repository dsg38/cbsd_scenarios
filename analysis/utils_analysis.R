#' @export
numCellsPopulated = function(values, coverage_fractions){
    return(sum(values>0, na.rm = TRUE))
}

#' @export
numCellsInPoly = function(values, coverage_fractions){
    return(length(values))
}
