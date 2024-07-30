suppressPackageStartupMessages({
  library(tidyverse)
  library(ggrepel)
  library(glue)
  library(scales)
  library(broom)
})

# data ---
comp_df <- read_csv("data/deluca_quality.csv",
  show_col_types = FALSE
)

# splits
coefs <- lm(split_for_D ~ quality_differential, comp_df) |>
  broom::tidy() |>
  rename(est = estimate, se = std.error) |>
  mutate(lbl = glue("{number(est, accuracy = 0.001)} ({number(se, accuracy = 0.001)})"))

# Graph ------
comp_df |>
  ggplot(aes(x = quality_differential, split_for_D)) +
  geom_point(aes(shape = state), size = 2) +
  geom_line(
    stat = "smooth", method = "lm", formula = y ~ x, se = FALSE,
    color = "navy", linewidth = 1, alpha = 0.3
  ) +
  geom_text_repel(aes(label = office), alpha = 0.4, size = 2, seed = 06510) +
  annotate("text",
    x = 2.5, y = Inf,
    label = glue("Slope:\n{coefs$lbl[coefs$term == 'quality_differential']}"),
    vjust = 1, hjust = 1, lineheight = 0.8, size = 3
  ) +
  scale_shape_discrete(labels = c("FL" = "Fla.", "MD" = "Md.", "SC" = "S.C.")) +
  scale_y_continuous(labels = scales::percent, expand = expansion(mult = c(0, 0.01))) +
  expand_limits(y = 0) +
  theme_classic() +
  labs(
    x = "Democratic Candidate Quality Advantage",
    y = "Split Ticket for Democrat candidate\namong Republicans",
    shape = "State"
  ) +
  theme(
    axis.text = element_text(color = "black"),
    legend.position = "bottom"
  )

ggsave("paper/figures/deluca_comparison.pdf", w = 4.4, h = 4)
