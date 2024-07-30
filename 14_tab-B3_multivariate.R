suppressPackageStartupMessages({
  library(tidyverse)
  # modeling
  library(arrow)
  library(fixest)

  # graphs
  library(modelsummary)
  options("modelsummary_format_numeric_latex" = "plain")
  library(ticketsplitJOPpkg)
})

# Data -----
dat_long <- open_dataset("data/by-votechoice/")

by_contest <- read_csv("data/by-contest_cand-metadata.csv",
  show_col_types = FALSE
) |>
  mutate(
    elec = as.character(elec),
    Rinc = replace(incumbency_R, open == 1, NA)
  )


# Run regressions ----
use_offices <- set_names(c("CCD", "SEN", "HOU", "SHF", "JPR", "USH"))
mods_all <-
  map(
    .x = use_offices,
    .f = \(j) {
      # outcome data
      y_dat <- dat_long |>
        filter(office == j) |>
        filter(!is.na(party)) |>
        mutate(voteR = as.numeric(party == 1)) |>
        select(voteR, D = Dvoter, elec, jID) |>
        collect()

      # join metadata
      meta_j <- filter(by_contest, office == j)
      dat_lm <- y_dat |>
        left_join(meta_j, by = c("elec", "jID"), relationship = "many-to-one")

      # fit regressions
      fit <- feols(voteR ~ D + Rinc + Rnewsadv + Rmoneyadv | elec, dat_lm,
        cluster = ~jID, notes = FALSE
      )

      fit
    },
    .progress = list(format = "Running office {cli::pb_current}")
  )

# table
mods_all[c("USH", "SEN", "HOU", "SHF", "JPR", "CCD")] |>
  modelsummary(
    coef_map = c(
      D = "Democratic Vote", Rinc = "Republican Incumbent",
      Rnewsadv = "Republican News Advantage",
      Rmoneyadv = "Republican Fundraising Advantage"
    ),
    stars = c("*" = 0.05),
    gof_map = c("nobs", "r.squared"),
    # output = "latex",
    fmt = 3
  )
