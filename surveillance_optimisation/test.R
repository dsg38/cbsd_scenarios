i = 0
objFuncVals = c()

objectiveFun = function(x){

    print(i)
    
    i <<- i + 1
    objFuncVals <<- c(objFuncVals, x)

    return(x)
}

startVec = 0

x = optimization::optim_sa(
    fun=objectiveFun,
    start=startVec,
    maximization=TRUE,
    trace=TRUE,
    lower=0,
    upper=0.01
)

plot(x$trace)

x$function_value

plot(objFuncVals)
