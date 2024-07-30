suppressPackageStartupMessages({
  library(tidyverse)
  library(arrow)
  library(scales)
  library(kableExtra)
})

# data ----
long_orig <- open_dataset("data/by-votechoice/")

# summarize by person ----
voter_lever <- long_orig |>
  filter(office == "PTY") |>
  select(elec, voter_id, lever = party)

# about 5-10 secs
person_split <- long_orig |>
  filter(ncand >= 2, office != "PTY") |>
  left_join(voter_lever,
    by = c("elec", "voter_id"),
    relationship = "many-to-one"
  ) |>
  select(elec, lever, voter_id, ncand, party) |>
  summarize(
    n_choices = n(),
    n_D = sum(party == -1),
    n_R = sum(party == 1),
    straight = sd(party) == 0,
    split = any(party == -1) & any(party == 1),
    .by = c(elec, voter_id, lever)
  ) |>
  collect()

# which party was preferred
person_fmt <- person_split |>
  mutate(n_more = pmax.int(n_D, n_R)) |>
  mutate(n_choices_chr = replace(as.character(n_choices), n_choices >= 9, "9 - 12"))

# make table -------
mk_tbl <- function(tbl = person_fmt) {
  tbl |>
    filter(n_choices > 1, (n_D > 0 | n_R > 0)) |>
    summarize(
      pct_straight = sum(straight) / n(),
      pct_split = sum(split) / n(),
      N = n(),
      pct_snolever = sum(straight * (lever == 0)) / sum(lever == 0),
      pct_spnolever = sum(split * (lever == 0)) / sum(lever == 0),
      N_nolever = sum(lever == 0),
      .groups = "drop"
    )
}

tab1 <- person_fmt |>
  group_by(n_choices_chr) |>
  mk_tbl() |>
  add_row(person_fmt |> mk_tbl(), n_choices_chr = "Total")

# tex file -----
tab_fmt <- tab1 |>
  mutate(across(c(N, N_nolever), number_format(accuracy = 1, scale = 0.001, suffix = "k", big.mark = ","))) |>
  mutate(across(where(is.numeric), number_format(accuracy = 0.01)))


# print
## uncomment to see tex output
# tab_fmt |>
#   kableExtra::kbl(booktabs = TRUE, format = "latex", linesep = "")
