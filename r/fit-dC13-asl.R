source("r/header.R")

d13C_asl = read_rds("processed-data/d13C-asl.rds") |>
  unite("plant_rep1", species:plant_rep, remove = FALSE) |>
  unite("leaf_rep1", species:leaf_rep, remove = FALSE)

fit_d = brm(
  bf(d_all_comp ~ asl + leaf_age + light_treatment) + 
    bf(asl ~ leaf_age + light_treatment) +
    set_rescor(FALSE),
  data = filter(d13C_asl, species == "paprika"),
  chains = 4L,
  iter = 2e3,
  thin = 1e0,
  cores = 4L,
  backend = "cmdstanr",
  seed = 662368844
)

conditional_effects(fit_d)

fit_c = brm(
  bf(d_all_comp ~ asl * species + leaf_age + light_treatment + (1|plant_rep1)) + 
    bf(asl ~ species + leaf_age + light_treatment + (1|plant_rep1)) +
    set_rescor(FALSE),
  data = d13C_asl,
  chains = 1L,
  iter = 2e3,
  thin = 1e0,
  cores = 1L,
  backend = "cmdstanr",
  seed = 142162167
)


library(lmerTest)
fit1 = lmer(
  d_all_comp ~ asl * species * leaf_age * light_treatment + 
    (1|plant_rep1),
  data = d13C_asl
)

anova(fit1)
fit2 = get_model(step(fit1))
coef(fit2)
confint(fit2)

get_model(fit2)
fit1 = brm(
  bf(
  d_all_comp ~ asl + species + leaf_age + light_treatment +
    asl:species + species:leaf_age + species:light_treatment +
    (1|plant_rep1), sigma ~ species
  ),
  data = d13C_asl,
  chains = 1L,
  iter = 2e3,
  thin = 1e0,
  cores = 1L,
  backend = "cmdstanr"
)

conditional_effects(fit1)


fit2 = brm(
  bf(d_all_comp ~ asl, sigma ~ species) + 
    bf(asl ~ species + leaf_age + light_treatment) +
    set_rescor(FALSE),
  data = d13C_asl,
  chains = 1L,
  iter = 2e3,
  thin = 1e0,
  cores = 1L,
  backend = "cmdstanr"
) |>
  add_criterion("loo")

conditional_effects(fit2)


fit3 = brm(
  bf(d_all_comp ~ asl * species + leaf_age + light_treatment + (1|plant_rep1)) + 
    bf(asl ~ species + leaf_age + light_treatment + (1|plant_rep1)) +
    set_rescor(FALSE),
  data = d13C_asl,
  chains = 1L,
  iter = 2e3,
  thin = 1e0,
  cores = 1L,
  backend = "cmdstanr"
) |>
  add_criterion("loo")

fit4 = brm(
  bf(d_all_comp ~ species + leaf_age + light_treatment + (1|plant_rep1)) + 
    bf(asl ~ species + leaf_age + light_treatment + (1|plant_rep1)) +
    set_rescor(FALSE),
  data = d13C_asl,
  chains = 1L,
  iter = 2e3,
  thin = 1e0,
  cores = 1L,
  backend = "cmdstanr"
) |>
  add_criterion("loo")

loo_compare(fit3, fit4)

bayestestR::mediation(fit3)
conditional_effects(fit3)



library(lavaan)
library(lavaanPlot)
model <- 'd_all_comp ~ asl + species + light_treatment
          asl ~ species + light_treatment '

fit <- sem(model, data = d13C_asl)
summary(fit)

lavaanPlot(model = fit, node_options = list(shape = "box", fontname = "Helvetica"), edge_options = list(color = "grey"), coefs = FALSE)
