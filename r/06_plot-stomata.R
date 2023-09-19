source("r/header.R")

# Figure 3A: Species and light versus SD
# I think area for count is 0.817 mm^2 based on Fig. 3 caption, but using 1-mm2 matches the figure

stomata = read_rds("processed-data/stomata.rds") |>
  filter(!is.na(stomatal_density_mm2)) |>
  summarize(
    stomatal_density_mm2 = mean(stomatal_density_mm2),
    n = n(),
    .by = c("species", "light_treatment", "plant_rep", "leaf_age", "leaf_rep",
            "surface")
  )

ggplot(stomata, aes(light_treatment, stomatal_density_mm2)) +
  facet_grid(leaf_age ~ species) +
  geom_point(
    mapping = aes(fill = light_treatment, shape = surface, group = surface),
    alpha = 0.5, shape = 21,
    position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.5)
  ) +
  stat_summary(
    geom = "pointrange", 
    mapping = aes(fill = light_treatment, shape = surface), 
    color = "black", position = position_dodge(width = 1)
  ) +
  xlab("Light treatment") +
  ylab(expression(Stomatal~density~bgroup("(", mm^-2, ")"))) +
  scale_fill_manual(values = c("grey", "yellow"), name = "Light treatment") +
  scale_shape_manual(values = c(21, 23)) +
  theme(legend.position = "none")

ggsave("figures/fig3a.pdf", width = 3.25, height = 4)

stomata |>
  pivot_wider(values_from = stomatal_density_mm2, names_from = surface) |>
  mutate(asl = adaxial / (adaxial + abaxial)) |>
  ggplot(aes(light_treatment, asl)) +
  facet_grid(leaf_age ~ species) +
  geom_point(
    mapping = aes(fill = light_treatment),
    alpha = 0.5, shape = 21,
    position = position_jitter(width = 0.05)
  ) +
  stat_summary(
    geom = "pointrange", 
    mapping = aes(fill = light_treatment), 
    shape = 21, color = "black", position = position_nudge(x = 0.1)
  ) +
  xlab("Light treatment") +
  ylab(expression(paste(amphistomy~level, ", ", SD[ad]/bgroup("(", SD[ad]+SD[ab], ")")))) +
  scale_fill_manual(values = c("grey", "yellow"), name = "Light treatment") +
  scale_shape_manual(values = c(21, 23)) +
  theme(legend.position = "none")

ggsave("figures/fig3b.pdf", width = 3.25, height = 4)
