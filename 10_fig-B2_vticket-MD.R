suppressPackageStartupMessages({
  library(tidyverse)
  library(arrow)
  library(patchwork)
  library(fs)
  library(ticketsplitJOPpkg)
})


# Data
wide_MD <- open_dataset("data/maryland")

#' Stack waffle plots by office
wstack_MD <- function(tbl, e, tit, dir = TRUE) {
  tbl <- tbl |> filter(elec %in% e)

  if (e == "2016") {
    gg <-
      gg_wfl_wide(tbl, USS, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, USH, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, PRS, rev = dir, check_ncand = FALSE, blank = TRUE) + # CCD
      gg_wfl_wide(tbl, PRS, rev = dir, check_ncand = FALSE, blank = TRUE) + # CIT
      gg_wfl_wide(tbl, CIP, rev = dir, check_ncand = FALSE, office_nam = "Baltimore<br>City Council<br>President") +
      gg_wfl_wide(tbl, MAY, rev = dir, check_ncand = FALSE, office_nam = "Baltimore Mayor") +
      gg_wfl_wide(tbl, CCE, rev = dir, check_ncand = FALSE, office_nam = "County Exec.,<br>Cecil County") +
      plot_layout(ncol = 1)
  }

  if (e == "2020") {
    gg <-
      gg_wfl_wide(tbl, PRS, rev = dir, check_ncand = FALSE, blank = TRUE) + # USS
      gg_wfl_wide(tbl, USH, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, CCD, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, CIT, rev = dir, check_ncand = FALSE, office_nam = "Baltimore<br>City Council") +
      gg_wfl_wide(tbl, CIP, rev = dir, check_ncand = FALSE, office_nam = "Baltimore<br>City Council<br>President") +
      gg_wfl_wide(tbl, MAY, rev = dir, check_ncand = FALSE, office_nam = "Baltimore Mayor") +
      gg_wfl_wide(tbl, CCE, rev = dir, check_ncand = FALSE, office_nam = "County Exec.,<br>Cecil County") +
      plot_layout(ncol = 1)
  }

  if (e == "2018") {
    gg <-
      gg_wfl_wide(tbl, USH, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, GOV, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, ATG, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, COM, rev = dir, check_ncand = FALSE, office_nam = "State Comptroller") +
      gg_wfl_wide(tbl, SEN, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, SHF, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, CDP, rev = dir, check_ncand = FALSE, office_nam = "County Council<br>President") +
      gg_wfl_wide(tbl, CCD, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, WIL, rev = dir, check_ncand = FALSE, office_nam = "Register of Wills") +
      gg_wfl_wide(tbl, ATG, rev = dir, check_ncand = FALSE, blank = TRUE) +
      plot_layout(ncol = 1)
  }

  if (e == "2022") {
    gg <-
      gg_wfl_wide(tbl, USH, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, GOV, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, ATG, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, COM, rev = dir, check_ncand = FALSE, office_nam = "State Comptroller") +
      gg_wfl_wide(tbl, SEN, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, SHF, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, CDP, rev = dir, check_ncand = FALSE, office_nam = "County Council<br>President") +
      gg_wfl_wide(tbl, CCD, rev = dir, check_ncand = FALSE) +
      gg_wfl_wide(tbl, WIL, rev = dir, check_ncand = FALSE, office_nam = "Register of Wills") +
      gg_wfl_wide(tbl, CLR, rev = dir, check_ncand = FALSE) +
      plot_layout(ncol = 1)
  }
  gg
}

d16 <- wstack_MD(filter(wide_MD, PRS == -1), e = "2016")
r16 <- wstack_MD(filter(wide_MD, PRS == 1), e = "2016")
d20 <- wstack_MD(filter(wide_MD, PRS == -1), e = "2020")
r20 <- wstack_MD(filter(wide_MD, PRS == 1), e = "2020")
d18 <- wstack_MD(filter(wide_MD, USS == -1), e = "2018")
r18 <- wstack_MD(filter(wide_MD, USS == 1), e = "2018")
d22 <- wstack_MD(filter(wide_MD, USS == -1), e = "2022")
r22 <- wstack_MD(filter(wide_MD, USS == 1), e = "2022")

# Plot ----
vw <- 1
vh <- 12 * 0.8
paper_dir <- "paper/figures/vticket"

ggsave(path(paper_dir, "vticket_MD-2016-Clinton.pdf"), d16, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_MD-2016-Trump.pdf"), r16, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_MD-2020-Biden.pdf"), d20, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_MD-2020-Trump.pdf"), r20, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_MD-2018-USS-D.pdf"), d18, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_MD-2018-USS-R.pdf"), r18, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_MD-2022-USS-D.pdf"), d22, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_MD-2022-USS-R.pdf"), r22, w = vw, h = vh)
