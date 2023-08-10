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