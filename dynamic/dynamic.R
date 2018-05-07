library(rstanarm)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
library(tidyverse)

voting_mrp <- readRDS(file = 'data/ModelData/voting_mrp.RDS')

# join Trump's voting results of 2016
voting_mrp <- voting_mrp %>% 
  dplyr::left_join(election_2016_results[, c(3, 11)], by=c("state"="State"))
colnames(voting_mrp)[13] <- "election_2016"
voting_mrp$election_2016 <- voting_mrp$election_2016 / 100

pref_formula <- cbind(Approve, Disapprove) ~
  1 + female + index + (1 + index | race) + (1 | age) + (1 | educ) + (1 | marstat) +
  # (1 | marstat:age) + (1 | marstat:state) + (1 | marstat:gender) + (1 | marstat:educ) + (1 | marstat:race) +
  # (1 | age:state) + (1 | age:gender) + (1 | age:educ) + (1 | age:race) +
  # (1 | state:gender) + (1 | state:educ) + (1 | state:race) +
  # (1 | gender:educ) + (1 | gender:race) +
  # (1 | educ:race)
  (1 | month) +
  (1 | month:state) +
  (1 + month + month_2 | state)

preference <- stan_glmer(pref_formula, family="binomial", data=voting_mrp,
                         iter=1000, cores=4, adapt_delta=0.99)

save(preference, file='preference.Rdata')