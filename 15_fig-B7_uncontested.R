library(tidyverse)
library(haven)
library(scales)

# Data ----
cc_fmt <- read_dta("data/hist-svy_cces.dta")
cd_contest <- read_dta("data/hist-svy_cd.dta")
cd_prox <- read_dta("data/hist-svy_cd-2020.dta") |>
  mutate(prox_lag = abs(pct_trump16 - 0.5))

# Summarize to districts ---
by_cd <- cc_fmt |>
  filter(year == 2020) |>
  semi_join(cd_contest, by = c("year", "st", "cd")) |>
  select(year, case_id, state, st, matches("cd"), split, weight) |>
  filter(!is.na(weight)) |>
  summarize(
    split = weighted.mean(split, weight, na.rm = TRUE),
    n = sum(weight),
    n_raw = n(),
    .by = c(year, cd)
  ) |>
  left_join(cd_prox, by = c("cd", "year"))

# What if districts were droppped ---
hyp_by_cd <- map(
  .x = 1:nrow(by_cd),
  .f = \(x) {
    by_cd |>
      slice_min(prox_lag, n = x) |>
      summarize(
        n_dists = n_distinct(cd),
        split_cum = sum(split * n) / sum(n),
        max_prox = max(prox_lag),
        n_cum = sum(n),
        n_cum_raw = sum(n_raw)
      )
  }
) |>
  list_rbind() |>
  mutate(
    moe = 1 / sqrt(n_cum_raw),
    dists_dropped = nrow(by_cd) - n_dists
  )


# Graph ---
max_dists <- nrow(by_cd)

gg_hyp <- hyp_by_cd |>
  ggplot(aes(x = dists_dropped, y = split_cum)) +
  geom_ribbon(aes(ymin = split_cum - moe, ymax = split_cum + moe), alpha = 0.3) +
  geom_line() +
  annotate("text",
    label = "Only retain districts with win margin less than:",
    vjust = 2,
    y = Inf,
    x = 200
  ) +
  geom_text(
    aes(
      y = Inf,
      label = scales::comma(max_prox, accuracy = 0.01)
    ),
    data = filter(hyp_by_cd, (dists_dropped) %% 25 == 0, dists_dropped < 400),
    hjust = 0,
    vjust = 6,
    size = 2
  ) +
  labs(
    x = "Number of Districts Dropped",
    y = "Ticket Split Rate\n(Retained Districts)"
  ) +
  annotate("text",
    label = "← More districts contested",
    x = 0, y = -Inf, hjust = 0, vjust = -0.5
  ) +
  annotate("text",
    label = "More districts uncontested\n(Lopsided districts drop) →",
    lineheight = 0.9,
    x = max_dists - 10, y = -Inf, hjust = 1, vjust = -0.2
  ) +
  coord_cartesian(ylim = c(0, 0.09)) +
  scale_x_continuous(expand = expansion(mult = c(0.005, 0.05))) +
  scale_y_continuous(labels = scales::percent, breaks = seq(0, 0.09, by = 0.03)) +
  theme_classic()

# Figure -----
ggsave("paper/figures/uncontested-robustness.png",
  gg_hyp,
  w = 5, h = 3
)
