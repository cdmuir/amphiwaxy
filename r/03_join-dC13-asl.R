source("r/header.R")

d13C = read_rds("processed-data/d13C.rds")
stomata = read_rds("processed-data/stomata.rds")

stomata |>
  pivot_wider(values_from = "stomatal_density_mm2", names_from = "surface") |>
  mutate(asl = adaxial / (abaxial + adaxial)) |>
  summarize(asl = mean(asl, na.rm = TRUE), .by = c(species:plant_rep)) |>
  right_join(d13C, by = join_by(species, light_treatment, leaf_age, plant_rep,
                                leaf_rep)) |>
  mutate(c_ratio_m1 = c_ratio - 1) |>
  write_rds("processed-data/d13C-asl.rds")
