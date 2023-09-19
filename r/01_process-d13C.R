source("r/header.R")

# Read original data to check against
d13C_original = read_excel(
  raw_data_file, sheet = "d13C-original",
  range = "A1:G109", col_types = c(rep("text", 5), rep("numeric", 2))
)

d13C_paprika = read_excel(
  raw_data_file, sheet = "d13C-paprika", 
  range = "A1:P109", col_types = c(rep("text", 6), rep("numeric", 10))
) 

d13C_broccoli = read_excel(
  raw_data_file, sheet = "d13C-broccoli", 
  range = "A1:L109", col_types = c(rep("text", 6), rep("numeric", 6))
) 

d13C_bulkleaf = read_excel(
  raw_data_file, sheet = "d13C-bulkleaf", 
  range = "A1:E37", col_types = c(rep("text", 4), "numeric")
) 

d13c_str = "^C[0-9]{2}[a-z]*_d13C$"
conc_str = "^C[0-9]{2}[a-z]*_µg_per_[0-9a-z]*"

# d13C_abaxial - d13C_adaxial for each chain length
df_delta_paprika = calc_delta(d13C_paprika)
df_delta_broccoli = calc_delta(d13C_broccoli)

# % composition of each chain length
df_abu_paprika = calc_abu(d13C_paprika)
df_abu_broccoli = calc_abu(d13C_broccoli)

df_abu_broccoli |>
  filter(light_treatment == "high", leaf_age == "young", plant_rep == "1", leaf_rep == "III")

# Calculate d_all_comp for each sample
d13C = full_join(
  bind_rows(df_delta_paprika, df_delta_broccoli),
  bind_rows(df_abu_paprika, df_abu_broccoli),
  by = join_by(species, light_treatment, leaf_age, plant_rep, leaf_rep, name)
) |>
  mutate(bottom = (abu_abaxial + abu_adaxial) / 2,
         top = d * bottom) |>
  summarize(
    d_all_comp = sum(top) / sum(bottom),
    .by = c(species, light_treatment, leaf_age, plant_rep, leaf_rep)
  ) |>
  left_join(d13C_bulkleaf,
            by = join_by(species, light_treatment, leaf_age, plant_rep)) |>
  mutate(c_ratio = 1 - (1 / (1 + ((dry_mass_delta_13C - delta_0 + a) / d_all_comp
  )))) |>
  factor_vars()

# Compare original to calculations
full_join(
  d13C_original, d13C,
  by = join_by(species, light_treatment, leaf_age, plant_rep, leaf_rep)
) |>
  # ggplot(aes(c_ratio.x, c_ratio.y)) +
  # geom_point()
  filter(abs(d_all_comp.x - d_all_comp.y) > 1e-3) |>
  select( d_all_comp.x,  d_all_comp.y)
  # filter(abs(c_ratio.x - c_ratio.y) > 1e-3)


write_rds(d13C, "processed-data/d13C.rds")
