x = read.table("./simulations/launch/YEV_posterior copy.txt")
x = cbind(x, lg = log(x$V4))

mean(x$lg)

mean(x$V2)
