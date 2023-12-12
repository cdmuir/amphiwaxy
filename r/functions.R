# Factor categorical variables
factor_vars = function(.d) {
  
  .d |>
    mutate(
      species = fct_recode(species, pepper = "paprika", broccoli = "broccoli"),
      species = factor(species, levels = c("pepper", "broccoli")),
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
prepare_new_data = function(.fit, .species, .explanatory) {
  
  .explanatory = switch(.explanatory, d_all_comp = "d_all_comp", c_ratio_m1 = "c_ratio_m1")
  
  .fit$data |>
    summarize(
      min = min(.data[[.explanatory]]), 
      max = max(.data[[.explanatory]]), 
      .by = c("leaf_age", "light_treatment")
    ) |>
    mutate(species = .species, range = max - min) |>
    crossing(.i = seq(0, 1, 0.01)) |>
    mutate(x = min + .i * range)
  
}

# Prepare posterior predictions
prepare_post_pred = function(.fit, .newdata, .explanatory) {
  
  .explanatory = switch(.explanatory, d_all_comp = "d_all_comp", c_ratio_m1 = "c_ratio_m1")
  
  ret = .fit |>
    as_draws_df() |>
    crossing(.newdata) |>
    mutate(
      intercept = b_asl_Intercept +
        b_asl_leaf_agemature * (leaf_age == "mature") +
        b_asl_leaf_ageold * (leaf_age == "old") +
        b_asl_light_treatmenthigh * (light_treatment == "high"),
      slope = !!sym(glue("b_asl_{.explanatory}")),
      asl = intercept + slope * x
    )
  
    return(ret)
  
}
