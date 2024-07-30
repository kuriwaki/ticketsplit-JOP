suppressPackageStartupMessages({
  library(tidyverse)
  library(arrow)
  library(scales)
  library(gt)
  library(ticketsplitJOPpkg)
})

# long data
long_orig <- open_dataset("data/by-votechoice/")

# Tabulate
inc_fracs <- long_orig |>
  filter(office %in% c("USH", "SEN", "HOU", "SHF", "CCD")) |>
  filter(!is.na(open), !is.na(copar)) |>
  count(office, open, inc_copar, copar) |>
  collect() |>
  mutate(group = case_when(
    open == 1 ~ "open",
    open == 0 & inc_copar == 1 ~ "inc",
    open == 0 & inc_copar == 0 ~ "chall",
  )) |>
  mutate(group_n = sum(n), .by = c(office, group)) |>
  mutate(frac = n / group_n)

# Format table -----
pp_fmt <- \(x) scales::number(x, accuracy = 0.01, style_positive = "plus")

inc_tbl <- inc_fracs |>
  filter(copar == 1) |>
  mutate(N = sum(n), .by = office) |>
  pivot_wider(
    id_cols = c(office, N),
    names_from = group,
    values_from = frac
  ) |>
  select(office, inc, chall, open, N) |>
  mutate(office = ticketsplitJOPpkg::recode_abbrv(office)) |>
  mutate(diff1 = pp_fmt(inc - chall), .after = chall) |>
  mutate(diff2 = pp_fmt(inc - open), .after = open) |>
  arrange(desc(N))

# for printing ---
inc_tbl |>
  gt() |>
  fmt_integer(N) |>
  fmt_number(c(inc, chall, open), decimals = 2) |>
  tab_spanner("Contests with an incumbent", columns = inc:diff1) |>
  tab_spanner("Open contests", columns = open) |>
  gt::as_latex() |>
  cat()
