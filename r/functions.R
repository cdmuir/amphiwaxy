# Factor categorical variables
factor_vars = function(.d) {
  
  .d |>
    mutate(
      species = factor(species, levels = c("paprika", "broccoli")),
      light_treatment = factor(light_treatment, levels = c("low", "high")),
      leaf_age = factor(leaf_age, levels = c("young", "mature", "old"))
    )
  
}

# Calculate d13C_abaxial - d13C_adaxial for each chain length
calc_delta = function(.d) {
  .d |>
    select(species:surface, matches(d13c_str)) |>
    pivot_longer(matches(d13c_str)) |>
    pivot_wider(names_from = surface) |>
    mutate(d = abaxial - adaxial, name = str_remove(name, "_d13C")) |>
    replace_na(list(d = 0)) |>
    select(-abaxial, -adaxial)
}

# Calculate % composition of each chain length
calc_abu = function(.d) {
  .d |>
    select(species:surface, matches(conc_str)) |>
    mutate(across(matches(conc_str), \(x) replace_na(x, 0))) |>
    rowwise() |>
    mutate(Ctotal = sum(c_across(matches(conc_str)))) |>
    mutate(across(matches(conc_str), \(.x) .x / Ctotal)) |>
    select(species:surface, matches(conc_str)) |>
    pivot_longer(matches(conc_str)) |>
    pivot_wider(names_from = surface) |>
    mutate(name = str_remove(name, "_µg_per_[0-9a-z]*")) |>
    rename(abu_abaxial = abaxial, abu_adaxial = adaxial)
}

# Prepare new data for posterior predictions
prepare_new_data = function(.fit, .species) {
  
  .fit$data |>
    summarize(
      min_asl = min(asl), max_asl = max(asl), 
      .by = c("leaf_age", "light_treatment")
    ) |>
    mutate(species = .species, range_asl = max_asl - min_asl) |>
    crossing(.i = seq(0, 1, 0.01)) |>
    mutate(asl = min_asl + .i * range_asl)
  
}

# Prepare posterior predictions
prepare_post_pred = function(.fit, .newdata, .response) {
  
  .response = switch(.response, dallcomp = "dallcomp", cratiom1 = "cratiom1")
  
  if (.response == "dallcomp") {
    ret = .fit |>
      as_draws_df() |>
      crossing(.newdata) |>
      mutate(
        intercept = b_dallcomp_Intercept +
          b_dallcomp_leaf_agemature * (leaf_age == "mature") +
          b_dallcomp_leaf_ageold * (leaf_age == "old") +
          b_dallcomp_light_treatmenthigh * (light_treatment == "high"),
        slope = b_dallcomp_asl,
        d_all_comp = intercept + slope * asl
      )
  }
  
  if (.response == "cratiom1") {
    ret = .fit |>
      as_draws_df() |>
      crossing(.newdata) |>
      mutate(
        intercept = b_cratiom1_Intercept +
          b_cratiom1_leaf_agemature * (leaf_age == "mature") +
          b_cratiom1_leaf_ageold * (leaf_age == "old") +
          b_cratiom1_light_treatmenthigh * (light_treatment == "high"),
        slope = b_cratiom1_asl,
        c_ratio_m1 = intercept + slope * asl
      )
  }
  
  return(ret)
}
