suppressPackageStartupMessages({
  library(tidyverse)
  library(haven)
  library(fixest)
  library(modelsummary)
})

tab <- read_csv("data/by-HOU-USH-dist_split.csv", show_col_types = FALSE)

options(modelsummary_factory_default = "kableExtra")
options(modelsummary_factory_latex = "kableExtra")
options(modelsummary_factory_html = "kableExtra")

# Regress ---
tab_reg <- tab |>
  filter(year >= 12) |>
  mutate(
    midterm = year %in% c(10, 14, 18),
    time = (year - 12) / 2
  )

lm2 <- feols(hstraight ~ time + midterm | USH_dist, tab_reg)
lm3 <- feols(hstraight ~ time + midterm | HOU_dist, tab_reg)

# summary stats
ss <- tab_reg |>
  summarize(
    mean = format(mean(hstraight), digits = 2),
    sd   = format(sd(hstraight), digits = 2),
  )

ss_tibb <- tribble(
  ~term, ~mod2, ~mod3,
  "Fixed Effects by", "Congressional District", "House District",
  "Avg. of Outcome", ss$mean[1], ss$mean[1],
  "Std. Dev of Outcome", ss$sd[1], ss$sd[1])

# modelsummary
modelsummary(list(lm2, lm3),
  fmt = 3,
  coef_map = c(time = "Time (2-Year Increment)", midtermTRUE = "Midterm Year"),
  stars = c("*" = 0.05),
  gof_map = c("nobs", "r.squared"),
  add_rows = ss_tibb
)

# tables/sth_ushouse_hdist.tex
