source("r/header.R")

d13C_asl = read_rds("processed-data/d13C-asl.rds") |>
  unite("plant_rep1", c(species, plant_rep), remove = FALSE)

fit_broccoli = brm(
  bf(asl ~ c_ratio_m1 + leaf_age + light_treatment + (1 | plant_rep1)) + 
    bf(c_ratio_m1 ~ leaf_age + light_treatment + (1 | plant_rep1)) +
    set_rescor(FALSE),
  data = filter(d13C_asl, species == "broccoli"),
  chains = 4L,
  iter = 16e3,
  thin = 8e0,
  cores = 4L,
  backend = "cmdstanr",
  seed = 748718405,
  control = list(adapt_delta = 0.99),
  silent = 0
)

fit_paprika = brm(
  formula(fit_broccoli),
  data = filter(d13C_asl, species == "paprika"),
  chains = 4L,
  iter = 16e3,
  thin = 8e0,
  cores = 4L,
  backend = "cmdstanr",
  seed = 110224734,
  control = list(adapt_delta = 0.99, max_treedepth = 12),
  silent = 0
)

write_rds(fit_broccoli, "objects/fit_dCi_broccoli.rds")
write_rds(fit_paprika, "objects/fit_dCi_paprika.rds")
