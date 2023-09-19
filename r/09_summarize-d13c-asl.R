# I copied tables into Word by hand

source("r/header.R")

fit_dC13_broccoli = read_rds("objects/fit_dC13_broccoli.rds")
fit_dC13_paprika  = read_rds("objects/fit_dC13_paprika.rds")
fit_dCi_broccoli  = read_rds("objects/fit_dCi_broccoli.rds")
fit_dCi_paprika   = read_rds("objects/fit_dCi_paprika.rds")

library(sjPlot)

tab_model(fit_dC13_broccoli)
tab_model(fit_dC13_paprika )
tab_model(fit_dCi_broccoli )
tab_model(fit_dCi_paprika  )
