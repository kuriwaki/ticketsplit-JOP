suppressPackageStartupMessages({
  library(tidyverse)
  library(glue)
  library(broom)
})

# Data ---
by_contest <- read_csv("data/by-contest_cand-metadata.csv",
  show_col_types = FALSE
)

# candidate level
by_cand <- by_contest |>
  select(jID, office, open, matches("incumbency_(D|R)"), matches("cfscore_(D|R)")) |>
  pivot_longer(
    -c(jID, office, open),
    names_to = c(".value", "party"),
    names_sep = "_"
  ) |>
  mutate(ico_status = case_when(
    open == 0 & (incumbency == 1) ~ "Incumbents",
    open == 0 & (incumbency == 0) ~ "Challengers",
    open == 1 ~ "Open Seat Candidates"
  )) |>
  filter(
    !is.na(ico_status),
    office %in% c("HOU", "SHF", "SEN", "USH", "CCD")
  ) |>
  mutate(ico_status = fct_relevel(
    ico_status,
    "Challengers",
    "Open Seat Candidates"
  ))

# Jitter boxplot ---
set.seed(02138)
gg_dime <- by_cand |>
  filter(!is.na(cfscore)) |>
  ggplot(aes(x = ico_status, y = cfscore, fill = party)) +
  geom_boxplot(alpha = 0.5, outlier.size = 0, color = "gray") +
  geom_jitter(aes(color = party),
    position = position_jitterdodge(
      jitter.width = 0.2,
      jitter.height = 0,
      seed = 02138
    ),
    alpha = 0.3,
    size = 0.5
  ) +
  scale_fill_manual(values = c(D = "navy", R = "indianred")) +
  scale_color_manual(values = c(D = "navy", R = "indianred")) +
  theme_classic() +
  guides(color = "none", fill = "none") +
  labs(x = NULL, y = "Estimated Candidate Positioning (CF-score)") +
  annotate("text",
    label = "← Liberal", color = "navy", size = 2.5,
    x = -Inf, y = -Inf, hjust = 0, vjust = -0.5
  ) +
  annotate("text",
    label = "Conservative →", color = "indianred", size = 2.5,
    x = -Inf, y = Inf, hjust = 1, vjust = -0.5
  ) +
  coord_flip() +
  theme(
    axis.text = element_text(color = "black"),
    axis.ticks.y = element_blank()
  )

suppressWarnings({
  print(gg_dime)
  ggsave("paper/figures/cfscore-by-incumbency.pdf", w = 4.5, h = 2.5)
})
