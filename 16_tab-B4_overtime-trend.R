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

lm1 <- lm(hsplt ~ time + midterm, tab_reg)
lm2 <- feols(hsplt ~ time + midterm | USH_dist, tab_reg)
lm3 <- feols(hsplt ~ time + midterm | HOU_dist, tab_reg)

tab_reg |>
  summarize(
    mean = mean(hsplt),
    sd = sd(hsplt),
  )

modelsummary(list(lm2, lm3),
  fmt = 3,
  coef_map = c(time = "Time (2-Year Increment)", midtermTRUE = "Midterm Year"),
  stars = c("*" = 0.05),
  gof_map = c("nobs", "r.squared")
)

# tables/sth_ushouse_hdist.tex

# Stata mode;
# esttab, replace///
#   style(tex) ///
#   booktab ///
#   label ///
#   varwidth(30) ///
#   mtitle("(1)" "(2)") ///
#   nodepvars ///
#   stats(fixed ymean ysd r2  N, ///
#           fmt(%s 2 2 2  %6.0fc) ///
#           labels("Fixed Effects by" "Average of Outcome" "Std. Dev. of Outcome" "R-squared" "Observations")) ///
#   obslast nonumbers nonotes  ///
#   starlevels(* 0.05) ///
#   b(a2) se(a1)
