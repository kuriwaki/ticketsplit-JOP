suppressPackageStartupMessages({
  library(tidyverse)
  library(haven)
  library(scales)
})


# Survey data ----
cc_fmt <- read_dta("data/hist-svy_cces.dta")
cd_contest <- read_dta("data/hist-svy_cd.dta")
anes_fmt <- read_dta("data/hist-svy_anes.dta")

# split ticket voting in contested CDs -----
cces_yr <- cc_fmt |>
  semi_join(cd_contest, by = c("year", "cd")) |>
  filter(year %% 4 == 0) |>
  group_by(year) |>
  filter(!is.na(weight)) |>
  filter(!is.na(split)) |> # rm 37% of rows
  summarize(
    n = sum(!is.na(split)),
    straight = weighted.mean(straight, weight, na.rm = TRUE),
    split = weighted.mean(split, weight, na.rm = TRUE),
    n_eff = sum(weight)^2 / sum(weight^2)
  ) |>
  ungroup() |>
  mutate(source = "CCES")

# ANES microdata ----
anes_df <- anes_fmt |>
  filter(year %% 4 == 0) |>
  semi_join(cd_contest, by = c("year", "cd")) |>
  mutate(split = case_when(
    hvote == 0 & pvote == 1 ~ 1,
    hvote == 1 & pvote == 0 ~ 1,
    hvote == 1 & pvote == 1 ~ 0,
    is.na(hvote) | is.na(pvote) ~ 0
  )) |>
  group_by(year) |>
  summarize(
    straight = weighted.mean(straight, weight, na.rm = TRUE),
    split = weighted.mean(split, weight, na.rm = TRUE),
    n_eff = sum(weight)^2 / sum(weight^2)
  ) |>
  mutate(source = "ANES")


# Plot ----
df_plot <- bind_rows(anes_df, cces_yr) |>
  mutate(
    se = sqrt(split * (1 - split)) / sqrt(n_eff),
    split = coalesce(split, 1 - straight)
  )

gg <- df_plot |>
  ggplot(aes(x = year, y = split, group = source, color = source)) +
  geom_line(linewidth = 1, alpha = 0.8, position = position_dodge(width = 0.5)) +
  geom_point(size = 2, position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = split - 2 * se, ymax = split + 2 * se),
    width = 0,
    position = position_dodge(width = 0.5),
    alpha = 0.5,
    linewidth = 0.8
  ) +
  geom_text(data = tribble(
    ~year, ~split, ~source,
    1957, 0.12, "ANES",
    2008, 0.04, "CCES",
  ), aes(label = source)) +
  geom_text(
    data = filter(df_plot, year == 2020),
    aes(label = scales::percent(split, accuracy = 0.1)),
    x = 2024.5
  ) +
  scale_color_manual(
    values = c("CCES" = "black", "ANES" = "gray45")
  ) +
  scale_x_continuous(
    breaks = seq(1956, 2020, by = 4),
    labels = function(x) str_c("'", str_sub(x, 3, 4)),
    minor_breaks = FALSE
  ) +
  scale_y_continuous(labels = percent, expand = expansion(mult = c(0, 0.1))) +
  expand_limits(y = 0) +
  expand_limits(x = 2025) +
  guides(group = "none", color = "none") +
  theme_classic() +
  labs(
    x = NULL,
    y = "President-Congress Split Ticket"
  )

ggsave("paper/figures/historical_straight-ticket-anes.pdf", gg,
  w = 4.5, h = 3
)
