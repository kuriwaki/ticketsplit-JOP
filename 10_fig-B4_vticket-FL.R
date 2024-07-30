suppressPackageStartupMessages({
  library(tidyverse)
  library(patchwork)
  library(fs)
  library(ticketsplitJOPpkg)
})


pty_to_num <- \(x) recode(x, D = -1, R = 1, O = 0.5, invalid = 0, .default = 0.5, .missing = NA_real_)

# Data -----
# read_rds("../clusterBallot/data/output/HerronLewis/FL-2000_PBC_fmt.rds") |>
#   write_csv("data/palmbeach/herron_lewis_counts.csv.gz")
ct_FL <- read_csv("data/palmbeach/herron_lewis_counts.csv.gz",
  show_col_types = FALSE
)

wide_FL <- ct_FL |>
  mutate(across(matches("v_"), ~ recode(.x, `2` = "D", `1` = "R", `0` = "undervote", .default = "other"))) |>
  uncount(weights = Nvoters) |>
  mutate(across(matches("v_"), pty_to_num))

# Plot function
wstack_FL <- function(tbl, tit, dir = TRUE) {
  tbl |>
    gg_wfl_wide(v_USS, rev = dir, check_ncand = FALSE, office_nam = "U.S. Senate") +
    gg_wfl_wide(tbl, v_USH, rev = dir, check_ncand = FALSE, office_nam = "U.S. House") +
    gg_wfl_wide(tbl, v_EDU, rev = dir, check_ncand = FALSE, office_nam = "State Education<br>Commissioner") +
    gg_wfl_wide(tbl, v_TRS, rev = dir, check_ncand = FALSE, office_nam = "State Treasurer") + # CIT
    gg_wfl_wide(tbl, v_SHF, rev = dir, check_ncand = FALSE, office_nam = "County Sheriff") +
    gg_wfl_wide(tbl, v_SOL, rev = dir, check_ncand = FALSE, office_nam = "Public Defender") +
    gg_wfl_wide(tbl, v_CLR, rev = dir, check_ncand = FALSE, office_nam = "Clerk of<br>County Court") +
    gg_wfl_wide(tbl, v_TAX, rev = dir, check_ncand = FALSE, office_nam = "County Tax<br>Collector") +
    plot_layout(ncol = 1)
}

# Plot -----
vw <- 1
vh <- 10
paper_dir <- "paper/figures/vticket"

d00 <- wstack_FL(filter(wide_FL, PRS == "Democrat"))
r00 <- wstack_FL(filter(wide_FL, PRS == "Republican"))

ggsave(path(paper_dir, "vticket_FL-2000-Gore.pdf"), d00, w = vw, h = vh)
ggsave(path(paper_dir, "vticket_FL-2000-Bush.pdf"), r00, w = vw, h = vh)
