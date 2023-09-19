source("r/header.R")

d13C_asl = read_rds("processed-data/d13C-asl.rds")
fit_broccoli = read_rds("objects/fit_dCi_broccoli.rds")
fit_paprika = read_rds("objects/fit_dCi_paprika.rds")

df_broccoli1 = prepare_new_data(fit_broccoli, "broccoli")
df_paprika1 = prepare_new_data(fit_paprika, "paprika")

df_broccoli2 = prepare_post_pred(fit_broccoli, df_broccoli1, "cratiom1")
df_paprika2 = prepare_post_pred(fit_paprika, df_paprika1, "cratiom1")

df_pred = bind_rows(df_broccoli2, df_paprika2) |>
  factor_vars() |>
  group_by(species, asl, leaf_age, light_treatment) |>
  point_interval(c_ratio_m1)

# Figure 5
ggplot(d13C_asl, aes(asl, c_ratio_m1, fill = light_treatment, shape = leaf_age)) +
  facet_wrap(~ species, scales = "free") +
  geom_ribbon(
    data = df_pred,
    mapping = aes(ymin = .lower, ymax = .upper, linetype = leaf_age), 
    alpha = 0.5, show.legend = TRUE
  ) +
  geom_line(
    data = df_pred,
    mapping = aes(linetype = leaf_age)
  ) +
  geom_point(size = 2) +
  scale_fill_manual(values = c("grey", "yellow"), name = "Light treatment") +
  scale_shape_manual(values = c(21, 22, 23), name = "Leaf age") +
  scale_linetype(name = "Leaf age") +
  ylab(expression(paste(CO[2], " gradient across the leaf, ", group("(", italic(c)[ad] - italic(c)[ab], ")") / italic(c)[ab]))) +
  xlab(expression(paste("amphistomy level, ASL ", bgroup("[",SD[ad] / bgroup("(", SD[ab] + SD[ad], ")"), "]")))) +
  theme(
    legend.position = "bottom", 
    legend.key.width = unit(1, "cm"),
    legend.direction = "vertical"
  ) +
  NULL
  
ggsave("figures/fig5c-d_base.png", width = 6.5, height = 6)
ggsave("figures/fig5c-d_base.pdf", width = 6.5, height = 6)
