library(ggplot2)
library(magrittr)
library(tidyr)
library(dplyr)
library(ggfan)

# generate mean and variance for sequence of samples over time
N_time <- 50
N_sims <- 1000 
time <- 1:N_time
mu <- time**2 * 0.03 + time * 0.3
sds <- exp(time**2 * -0.001 + time * 0.1)

# simulate 1000 samples from each time point
fake_data <- sapply(time, function(i) rnorm(N_sims, mu[i], sds[i]))

# gather into a long-form, tidy dataset
fake_df <- data.frame(x=time, t(fake_data)) %>% gather(key=Sim, value=y, -x)

p <- ggplot(fake_df, aes(x=x,y=y)) + geom_fan()
print(p)
