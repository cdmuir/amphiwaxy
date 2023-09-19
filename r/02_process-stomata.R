source("r/header.R")

read_excel(
  raw_data_file, sheet = "stomata", range = "A1:I1081", 
  col_types = c(rep("text", 8), "numeric")
) |>
  mutate(stomatal_density_mm2 = stomata_count / 1) |>
  factor_vars() |>
  select(-stomata_count) |>
  write_rds("processed-data/stomata.rds")
