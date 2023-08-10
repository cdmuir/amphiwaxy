source("r/header.R")

d13C_asl = read_rds("processed-data/d13C-asl.rds")


# Figure 5
ggplot(d13C_asl, aes(d_all_comp, asl, color = light_treatment, shape = leaf_age)) +
  facet_wrap(~ species, scales = "free") +
  geom_point()
