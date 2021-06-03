#' @export
subsetResultsDf = function(
    resultsDf,
    polySuffix=NULL,
    passKeys=NULL
){
    
    outDf = resultsDf
    
    if(!is.null(polySuffix)){
        outDf = outDf[outDf$polySuffix==polySuffix,]
    }
    
    if(!is.null(passKeys)){
        outDf = outDf[outDf$simKey%in%passKeys,]
    }
    
    return(outDf)
    
}

#' @export
noInfSpecificPoly = function(
    resultsDf,
    polyName
){
    
    polyDf = resultsDf[resultsDf$polyName==polyName,]
    
    polyDfPass = polyDf[polyDf$infProp==0,]
    
    passKeys = unique(polyDfPass$simKey)
    
    return(passKeys)
}


#' @export
anyInfSpecificPoly = function(
    resultsDf,
    polyName
){
    
    polyDf = resultsDf[resultsDf$polyName==polyName,]
    
    polyDfPass = polyDf[polyDf$infProp > 0,]
    
    passKeys = unique(polyDfPass$simKey)
    
    return(passKeys)
}

#' @export
applyConstraintList = function(
    resultsDf,
    constraints
){

    passKeysList = list()

    polyNameVec = names(constraints)
    for(polyName in polyNameVec){
        
        tol = constraints[[polyName]]
        
        passDf = applySpecificPoly(
            resultsDf = resultsDf,
            polyName = polyName,
            tol = tol
        )
        
        passKeysList[[polyName]] = unique(passDf$simKey)
        
    }

    passKeys = Reduce(intersect, passKeysList)

    return(passKeys)

}

applySpecificPoly = function(
    resultsDf,
    polyName,
    tol
){
    
    polyDf = resultsDf[resultsDf$polyName==polyName,]

    passKeys = applyTolConstraint(
        polyDf=polyDf,
        tol=tol
    )

    return(passKeys)

}

#' @export
applyAllPolySuffix = function(
    resultsDf,
    polySuffix,
    tol
){
    
    polyDf = resultsDf[resultsDf$polySuffix==polySuffix,]

    passKeys = applyTolConstraint(
        polyDf=polyDf,
        tol=tol
    )

    return(passKeys)

}

applyTolConstraint = function(
    polyDf,
    tol
){

    polyKeysAll = unique(polyDf$simKey)
    
    dropKeys = polyDf[abs(polyDf$targetDiff)>tol, "simKey"]
    
    passKeysBool = !(polyKeysAll %in% dropKeys)
    passKeys = polyKeysAll[passKeysBool]
    
    return(passKeys)

}

#' @export
plotInfProp = function(
    resultsDf,
    tol=NULL
    # title, 
    # outPath
    ){

    box::use(
        ggplot2[...],
        ggfan[...],
    )
    
    resultsDf$surveyDataYear = as.numeric(resultsDf$surveyDataYear)
    
    p = ggplot(data=resultsDf, aes(x=surveyDataYear, y=infProp)) +
        geom_fan(intervals = seq(0,1,0.2)) +
        scale_fill_gradient(low="#5D5DF8", high="#C1C1EF") +
        ylim(0,1)+
        geom_line(aes(x=surveyDataYear, y=targetVal), color="red")+
        geom_point(aes(x=surveyDataYear, y=targetVal), color="red", fill="red")


    if(!is.null(tol)){

        tolMin = resultsDf$targetVal - tol
        tolMin[tolMin<0] = 0
        
        tolMax = resultsDf$targetVal + tol
        tolMax[tolMax>1] = 1   

        targetDf = unique(data.frame(   
            surveyDataYear=resultsDf$surveyDataYear,
            targetVal=resultsDf$targetVal,
            tolMin=tolMin,
            tolMax=tolMax
        ))

        p = p + geom_point(data=targetDf, aes(x=surveyDataYear, y=tolMax), color="green", shape=25, fill="green") +
            geom_point(data=targetDf, aes(x=surveyDataYear, y=tolMin), color="green", shape=24, fill="green")
    }

    # ggtitle(title)
    # ggsave(outPath)

    return(p)
    
}

