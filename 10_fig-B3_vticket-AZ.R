suppressPackageStartupMessages({
  library(tidyverse)
  library(patchwork)
  library(fs)
  library(ticketsplitJOPpkg)
})

# Contested districts
cont_dists_sen <- c(1, 4, 12, 17, 18, 20, 22, 23, 24, 25, 26, 28, 29)
cont_dists_ccd <- c(1, 2, 3, 4)

pty_to_num <- \(x) recode(x, D = -1, R = 1, O = 0.5, invalid = 0, .default = NA_real_)

# Data
voter_party <- read_csv("data/maricopa/ballots_wide_party.csv.gz",
  show_col_types = FALSE
)
voter_party_num <- voter_party |>
  mutate(across(matches("_party"), pty_to_num))


# Plot function
wstack_AZ <- function(tbl) {
  sen <- filter(tbl, SEN_dist %in% cont_dists_sen)
  ccd <- filter(tbl, CCD_dist %in% cont_dists_ccd)

  gg <-
    gg_wfl_wide(tbl, USS_party, check_ncand = FALSE) +
    gg_wfl_wide(tbl, USH_party, check_ncand = FALSE) +
    gg_wfl_wide(sen, SEN_party, check_ncand = FALSE) +
    gg_wfl_wide(tbl, SHF_party, check_ncand = FALSE) +
    gg_wfl_wide(ccd, CCD_party, check_ncand = FALSE) +
    gg_wfl_wide(tbl, CSS_party, check_ncand = FALSE, office_nam = "County School<br>Superintendent") +
    gg_wfl_wide(tbl, CAT_party, check_ncand = FALSE, office_nam = "County Attorney") +
    gg_wfl_wide(tbl, CRC_party, check_ncand = FALSE, office_nam = "County Recorder") +
    gg_wfl_wide(tbl, CTR_party, check_ncand = FALSE) +
    gg_wfl_wide(tbl, JPM_party, check_ncand = FALSE, office_nam = "Judge,<br>Moon Valley") +
    plot_layout(ncol = 1)

  gg
}

# Plot -----
vw <- 1
vh <- 10
paper_dir <- "paper/figures/vticket"

d20 <- wstack_AZ(filter(voter_party_num, PRS_party == -1))
r20 <- wstack_AZ(filter(voter_party_num, PRS_party == 1))

ggsave(path(paper_dir, "vticket_AZ-2020-Biden.pdf"), d20, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_AZ-2020-Trump.pdf"), r20, w = vw, h = vh)