suppressPackageStartupMessages({
  library(tidyverse)
  library(arrow)
  library(patchwork)
  library(fs)
  library(ticketsplitJOPpkg)
})

# Large data
long <- open_dataset("data/by-votechoice/")

#' Stack waffle plots by office
#' @param e election code
wstack_SC <- function(tbl, e) {
  tbl <- tbl |> filter(elec %in% e)

  if (e == "2016-11-08") {
    gg <-
      gg_wfl_long(tbl, "USS") +
      gg_wfl_long(tbl, "USH") +
      gg_wfl_long(tbl, "SEN") +
      gg_wfl_long(tbl, "HOU") +
      gg_wfl_long(tbl, "SHF") +
      gg_wfl_long(tbl, "PRS", blank = TRUE) + # JPRB
      gg_wfl_long(tbl, "CCD") +
      gg_wfl_long(tbl, "CTR") +
      gg_wfl_long(tbl, "AUD") +
      gg_wfl_long(tbl, "CLR") +
      plot_layout(ncol = 1)
  }


  if (e == "2012-11-06") {
    gg <-
      gg_wfl_long(tbl, "PRS", blank = TRUE) + # USSEN
      gg_wfl_long(tbl, "USH") +
      gg_wfl_long(tbl, "SEN") +
      gg_wfl_long(tbl, "HOU") +
      gg_wfl_long(tbl, "SHF") +
      gg_wfl_long(tbl, "JPR") +
      gg_wfl_long(tbl, "CCD") +
      gg_wfl_long(tbl, "CTR") +
      gg_wfl_long(tbl, "AUD") +
      gg_wfl_long(tbl, "CLR") +
      plot_layout(ncol = 1)
  }

  if (e == "2018-11-06") {
    gg <-
      gg_wfl_long(tbl, "GOV", blank = TRUE) + # USSEN
      gg_wfl_long(tbl, "USH") +
      gg_wfl_long(tbl, "GOV", blank = TRUE) + # GOV
      gg_wfl_long(tbl, "GOV", blank = TRUE) + # LGV
      gg_wfl_long(tbl, "ATG") +
      gg_wfl_long(tbl, "SOS") +
      gg_wfl_long(tbl, "GOV", blank = TRUE, office_nam = "School\nSuperintendent") + # SSI
      gg_wfl_long(tbl, "HOU") +
      gg_wfl_long(tbl, "JPR") +
      gg_wfl_long(tbl, "CCD") +
      plot_layout(ncol = 1)
  }

  if (e == "2014-11-04") {
    gg <-
      gg_wfl_long(tbl, "USS2", office_nam = "US Senate\nSpecial") +
      gg_wfl_long(tbl, "USH") +
      gg_wfl_long(tbl, "GOV") +
      gg_wfl_long(tbl, "LGV") +
      gg_wfl_long(tbl, "ATG") +
      gg_wfl_long(tbl, "SOS") +
      gg_wfl_long(tbl, "SSI", office_nam = "School\nSuperintendent") +
      gg_wfl_long(tbl, "HOU") +
      gg_wfl_long(tbl, "JPR") +
      gg_wfl_long(tbl, "CCD") +
      plot_layout(ncol = 1)
  }

  if (e == "2010-11-02") {
    gg <-
      gg_wfl_long(tbl, "USH", blank = TRUE) + # USS2
      gg_wfl_long(tbl, "USH") +
      gg_wfl_long(tbl, "GOV") +
      gg_wfl_long(tbl, "LGV") +
      gg_wfl_long(tbl, "ATG") +
      gg_wfl_long(tbl, "SOS") +
      gg_wfl_long(tbl, "SSI", office_nam = "School\nSuperintendent") +
      gg_wfl_long(tbl, "HOU") +
      gg_wfl_long(tbl, "JPR") +
      gg_wfl_long(tbl, "CCD") +
      plot_layout(ncol = 1)
  }
  return(gg)
}

d12 <- wstack_SC(filter(long, top_party2 == -1), e = "2012-11-06")
r12 <- wstack_SC(filter(long, top_party2 == 1), e = "2012-11-06")
d16 <- wstack_SC(filter(long, top_party2 == -1), e = "2016-11-08")
r16 <- wstack_SC(filter(long, top_party2 == 1), e = "2016-11-08")
d10 <- wstack_SC(filter(long, top_party2 == -1), e = "2010-11-02")
r10 <- wstack_SC(filter(long, top_party2 == 1), e = "2010-11-02")
d14 <- wstack_SC(filter(long, top_party2 == -1), e = "2014-11-04")
r14 <- wstack_SC(filter(long, top_party2 == 1), e = "2014-11-04")
d18 <- wstack_SC(filter(long, top_party2 == -1), e = "2018-11-06")
r18 <- wstack_SC(filter(long, top_party2 == 1), e = "2018-11-06")


# Plot ----
vw <- 1
vh <- 12
paper_dir <- "paper/figures/vticket"

ggsave(path(paper_dir, "vticket_2012-Obama.pdf"), d12, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2016-Clinton.pdf"), d16, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2012-Romney.pdf"), r12, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2016-Trump.pdf"), r16, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2018-Smith.pdf"), d18, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2018-McMaster.pdf"), r18, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2014-USS-D.pdf"), d14, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2014-USS-R.pdf"), r14, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2010-USS-D.pdf"), d10, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_2010-USS-R.pdf"), r10, w = vw, h = vh)
