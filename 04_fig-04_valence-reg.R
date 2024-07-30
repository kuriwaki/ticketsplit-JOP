suppressPackageStartupMessages({
  library(tidyverse)
  # modeling
  library(arrow)
  library(fixest)
  setFixest_notes(FALSE)
  library(marginaleffects)

  # graphs
  library(ggtext)
  library(lemon)
  library(fs)
  library(scales)
  library(patchwork)
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

# Sum stats for rescaling coefs later
sumstats <- by_contest |>
  filter(office %in% c("USH", "SEN", "HOU", "SHF", "CCD", "JPR")) |>
  summarize(
    Rmoneyadv = sd(Rmoneyadv, na.rm = TRUE),
    Rnewsadv = sd(Rnewsadv, na.rm = TRUE),
    .by = office
  ) |>
  pivot_longer(-office, names_to = "outcome", values_to = "outcome_sd")


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
        mutate(copar = ifelse(party %in% c(0, 0.5), NA, copar)) |>
        select(elec, D = Dvoter, copar, jID) |>
        mutate(split = -1 * (copar - 1)) |>
        collect()

      # join metadata
      meta_j <- filter(by_contest, office == j)
      dat_lm <- y_dat |>
        left_join(meta_j, by = c("elec", "jID"), relationship = "many-to-one")

      # fit regressions
      fit1 <- feols(split ~ Rinc * (1 + D + I(D^2)) | elec, dat_lm, cluster = ~jID)
      fit2 <- feols(split ~ Rnewsadv * (1 + D + I(D^2)) | elec, dat_lm, cluster = ~jID)
      fit3 <- feols(split ~ Rmoneyadv * (1 + D + I(D^2)) | elec, dat_lm, cluster = ~jID)

      # For that office, summarize marginal effects in tibble
      map(
        list(Rinc = fit1, Rnewsadv = fit2, Rmoneyadv = fit3),
        \(x) {
          marginaleffects::slopes(
            x,
            newdata = marginaleffects::datagrid(D = c(0, 1))
          ) |>
            select(term, est = estimate, se = std.error, Dvoter = D) |>
            filter(term != "D") |>
            as_tibble()
        }
      ) |>
        list_rbind(names_to = "treatment")
    },
    .progress = list(format = "Running office {cli::pb_current}")
  ) |>
  list_rbind(names_to = "office")

# Coefs for printing -----
office_lbl <- c(
  "USH" = "US House",
  "SEN" = "State Senate",
  "HOU" = "State House",
  "SHF" = "County Sheriff",
  "JPR" = "Probate Judge",
  "CCD" = "County Council"
)

treat_lbl2 <- c(
  "Rinc" = "Effect of<br>Republican __Incumbent__",
  "Rnewsadv" = "Effect of 1 s.d. Republican <br>__News Coverage__ Advantage",
  "Rmoneyadv" = "Effect of 1 s.d. Republican <br>__Fundraising__ Advantage"
)

coefs_fmt <- coefs_all |>
  left_join(sumstats, by = c("treatment" = "outcome", "office")) |>
  mutate(outcome_sd = replace(outcome_sd, treatment == "Rinc", 1)) |>
  mutate(office = fct_relevel(office, "USH", "SEN", "HOU", "SHF", "JPR", "CCD")) |>
  relocate(treatment, office) |>
  mutate(
    voter_type = recode(Dvoter, `0` = "Republican", `1` = "Democrat"),
    office_fmt = fct_rev(recode_factor(office, !!!office_lbl)),
    treatment = fct_relevel(treatment, "Rinc", "Rnewsadv", "Rmoneyadv")
  )

#' Plot ----
gg_newplot <- function(dvote, data = coefs_fmt, col, col2 = "black") {
  data |>
    filter(Dvoter %in% dvote) |>
    mutate(
      lb1 = (est - qnorm(0.975) * se) * outcome_sd,
      lb2 = (est - qnorm(0.9) * se) * outcome_sd,
      ub1 = (est + qnorm(0.975) * se) * outcome_sd,
      ub2 = (est + qnorm(0.9) * se) * outcome_sd,
    ) |>
    ggplot(aes(x = est * outcome_sd, y = office_fmt)) +
    facet_rep_grid(~treatment,
      scales = "free_x",
      repeat.tick.labels = TRUE,
      labeller = labeller(treatment = treat_lbl2)
    ) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    geom_errorbarh(aes(xmin = lb2, xmax = ub2), alpha = 1, height = 0, color = col, linewidth = 2) + # 80%
    geom_errorbarh(aes(xmin = lb1, xmax = ub1), alpha = 1, height = 0, color = col, linewidth = 1) + # 95%
    geom_text(aes(label = number(est * outcome_sd, scale = 100, accuracy = 0.1)),
      color = col2, vjust = -1, size = 2
    ) +
    theme_classic() +
    expand_limits(x = 0.03) +
    expand_limits(x = -0.03) +
    scale_x_continuous(labels = scales::unit_format(scale = 100, accuracy = 1, unit = "pp", sep = ""), ) +
    labs(
      x = "Marginal Effect on Ticket Splitting",
      y = NULL, caption = NULL
    ) +
    theme(
      axis.text.x = element_text(color = "black", size = 7.5),
      strip.text.x = element_markdown(size = 9.3),
      plot.title = element_markdown(hjust = 0.5),
      plot.caption = element_text(color = "darkgray"),
      strip.background = element_rect(color = "transparent", fill = "lightgray")
    )
}

gg_D <- gg_newplot(dvote = 1, col = "dodgerblue", col2 = "navy") +
  labs(title = "Among voters who voted <span style = 'color:navy;'>Democratic</span> at the top of the ticket:")
gg_R <- gg_newplot(dvote = 0, col = "indianred", col2 = "darkred") +
  labs(title = "Among voters who voted <span style = 'color:darkred;'>Republican</span> at the top of the ticket:")

paper_dir <- "paper/figures"
ggsave(path(paper_dir, "valencegraph_D.pdf"), gg_D, w = 8.1, h = 2.5)
ggsave(path(paper_dir, "valencegraph_R.pdf"), gg_R, w = 8.1, h = 2.5)
