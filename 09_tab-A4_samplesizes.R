suppressPackageStartupMessages({
  library(tidyverse)
  library(haven)
  library(arrow)
})

# Data ----
wide_analysis <- open_dataset("data/by-person-ID")

# voters -----
n_voters_yr <- wide_analysis |>
  summarize(
    n_counties = n_distinct(county),
    n_precincts = n_distinct(precinct_id),
    n = n(),
    .by = elec
  ) |>
  collect()

n_voters <- n_voters_yr |>
  add_row(
    elec = "Total",
    n = sum(n_voters_yr$n),
    n_counties = sum(n_voters_yr$n_counties),
    n_precincts = sum(n_voters_yr$n_precincts)
  ) |>
  mutate(n = str_c(format(round(n / 1000), big.mark = ","), "k"))

# contests -----
n_contests_yr <- wide_analysis |>
  summarize(
    USH = n_distinct(USH_jID, na.rm = TRUE),
    SEN = n_distinct(SEN_jID, na.rm = TRUE),
    HOU = n_distinct(HOU_jID, na.rm = TRUE),
    SHF = n_distinct(SHF_jID, na.rm = TRUE),
    JPR = n_distinct(JPR_jID, na.rm = TRUE),
    CCD = n_distinct(CCD_jID, na.rm = TRUE),
    .by = elec
  ) |>
  collect()

n_contests <- n_contests_yr |>
  add_row(
    elec = "Total",
    USH = sum(n_contests_yr$USH),
    SEN = sum(n_contests_yr$SEN),
    HOU = sum(n_contests_yr$HOU),
    SHF = sum(n_contests_yr$SHF),
    JPR = sum(n_contests_yr$JPR),
    CCD = sum(n_contests_yr$CCD)
  )


# combine (final table) -----
left_join(n_contests, n_voters, by = "elec") |>
  mutate(across(where(is.numeric), as.character)) |>
  pivot_longer(-elec) |>
  pivot_wider(id_cols = name, names_from = elec)
