suppressPackageStartupMessages({
  library(tidyverse)
  # modeling
  library(arrow)
  library(fixest)
  library(marginaleffects)

  # graphs
  library(ggtext)
  library(lemon)
  library(fs)
  library(scales)
  library(patchwork)
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
coefs_all <-
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
      fit <- feglm(voteR ~ Rinc + D | elec, dat_lm,
        family = "binomial",
        cluster = ~jID, notes = FALSE
      )

      # summarize marginal effects in tibble
      marginaleffects::predictions(
        fit,
        newdata = marginaleffects::datagrid(D = seq(0, 1, by = 0.2), Rinc = c(0, 1))
      ) |>
        select(Dvoter = D, Rinc, est = estimate, lb = conf.low, ub = conf.high) |>
        as_tibble()
    },
    .progress = list(format = "Running office {cli::pb_current}")
  ) |>
  list_rbind(names_to = "office")


# Graph and print ---
lab_df <- tribble(
  ~Rinc, ~Dvoter, ~est, ~lab, ~hj,
  0, 0.5, 0.20, "Republican not\nan incumbent", 1,
  1, 0.5, 0.75, "Republican is\nan incumbent", 0,
) |>
  mutate(office = factor("SEN", levels = c("USH", "SEN", "HOU", "SHF", "JPR", "CCD")))

coefs_fmt <- coefs_all |>
  mutate(office = fct_relevel(office, "USH", "SEN", "HOU", "SHF", "JPR", "CCD"))

ggplot(coefs_fmt, aes(x = Dvoter, y = est, color = factor(Rinc), group = factor(Rinc))) +
  lemon::facet_rep_wrap(~office, labeller = labeller(office = ticketsplitJOPpkg::recode_abbrv)) +
  geom_line(linewidth = 0.5, position = position_dodge(width = 0.02)) +
  geom_point(position = position_dodge(width = 0.02)) +
  geom_errorbar(aes(ymin = lb, ymax = ub),
    position = position_dodge(width = 0.02),
    width = 0,
    alpha = 0.5
  ) +
  scale_y_continuous(labels = percent_format(accuracy = 1), expand = c(0, 0)) +
  scale_color_manual(values = c(`0` = "#010d9a", `1` = "#e66101")) +
  geom_text(data = lab_df, aes(label = lab, hjust = hj), size = 3) +
  guides(color = "none") +
  coord_cartesian(ylim = c(0, 1)) +
  theme_classic() +
  theme(
    strip.background = element_blank(),
    strip.text = element_text(face = "bold")
  ) +
  labs(
    x = "Democratic Vote at Top of the Ticket",
    y = "Vote Republican in .."
  ) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))


ggsave("paper/figures/inc-margins_phat.pdf",
  w = 7,
  h = 4.5
)
