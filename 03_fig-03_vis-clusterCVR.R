suppressPackageStartupMessages({
  library(tidyverse)
  library(scales)
  library(glue)
  library(patchwork)
  library(ticketsplitJOPpkg)
  library(fs)
})

# Clustering estimates ----
c12_D <- read_rds("data/clusters/p12_D-subset_k4.rds")
c12_R <- read_rds("data/clusters/p12_R-subset_k4.rds")
c16_D <- read_rds("data/clusters/p16_D-subset_k4.rds")
c16_R <- read_rds("data/clusters/p16_R-subset_k4.rds")

fmt_mu_viz2 <- function(x, custom = NULL) {
  # reorder by pi
  clnum_reord <- fmt_mu_viz(x) |>
    distinct(cluster, pi) |>
    arrange(desc(pi))

  if (!is.null(custom)) {
    clnum_reord <- clnum_reord[custom, ]
  }

  new_labs <- clnum_reord |>
    mutate(cl_lbl = glue("Cluster {1:n()} ({scales::percent(pi, accuracy = 1)})")) |>
    transmute(cluster, cl_lbl = as.character(cl_lbl))

  fmt_mu_viz(x) |>
    left_join(new_labs, by = "cluster", relationship = "many-to-one") |>
    mutate(pct_lbl = replace(pct_lbl, mu < 0.12, ""))
}

# update to fix numbering
mus_R12 <- fmt_mu_viz2(get_mus(c12_R), custom = c(2, 1, 4, 3))
mus_R16 <- fmt_mu_viz2(get_mus(c16_R), custom = c(1, 2, 3, 4))

mus_D12 <- fmt_mu_viz2(get_mus(c12_D), custom = c(1, 2, 3, 4))
mus_D16 <- fmt_mu_viz2(get_mus(c16_D), custom = c(1, 2, 3, 4))

# Modify labels  -----
rm_paren <- function(x) str_remove_all(x, "[\\(\\)]")
lb_clus12 <- function(x) {
  stringi::stri_replace_all_fixed(
    rm_paren(x),
    c("Cluster 1 ", "Cluster 2 ", "Cluster 3 ", "Cluster 4 "),
    c(
      "Cluster 1\n(Solid Partisans)\n", "Cluster 2\n(Selective Swing)\n",
      "Cluster 3\n(Roll-off)\n", "Cluster 4\n(Selective Swing)\n"
    ),
    vectorize_all = FALSE
  )
}
lb_clus16 <- function(x, top = "D") {
  stringi::stri_replace_all_fixed(
    rm_paren(x),
    c("Cluster 1 ", "Cluster 2 ", "Cluster 3 ", "Cluster 4 "),
    c(
      "Cluster 1\n(Solid Partisans)\n", "Cluster 2\n(Selective Swing)\n",
      "Cluster 3\n(Roll-off)\n",
      as.character(glue("Cluster 4\n({ifelse(top == 'D', 'Anti-Trump R)\n', 'General Swing)\n')}"))
    ),
    vectorize_all = FALSE
  )
}
mus_R12_fmt <- mus_R12 |> mutate(cl_lbl = lb_clus12(cl_lbl), vote = recode(vote, Abstain = "Roll-off"))
mus_R16_fmt <- mus_R16 |> mutate(cl_lbl = lb_clus16(cl_lbl, top = "R"), vote = recode(vote, Abstain = "Roll-off"))

mus_D12_fmt <- mus_D12 |> mutate(cl_lbl = lb_clus12(cl_lbl), vote = recode(vote, Abstain = "Roll-off"))
mus_D16_fmt <- mus_D16 |> mutate(cl_lbl = lb_clus16(cl_lbl, top = "D"), vote = recode(vote, Abstain = "Roll-off"))

# write graph base ------
gg_cl <- mus_R12 |>
  ggplot(aes(x = mu, y = fct_rev(office), fill = fct_relevel(vote, "Roll-off", "Straight", "Split"))) +
  facet_wrap(~cl_lbl, nrow = 1) +
  geom_col(width = 0.5) +
  theme_classic() +
  guides(fill = guide_legend(name = "", reverse = TRUE)) +
  geom_text(aes(label = pct_lbl),
    position = position_stack(vjust = 0.9),
    hjust = 0.8,
    size = 2.5,
    alpha = 0.8,
    color = "white",
    family = "mono",
    na.rm = TRUE
  ) +
  theme(
    legend.position = "bottom",
    axis.text = element_text(color = "black"),
    axis.line.y = element_blank()
  ) +
  scale_x_continuous(expand = c(0, 0)) +
  labs(
    y = "",
    x = "Probability of Voting ...",
    fill = ""
  ) +
  theme(
    panel.spacing = unit(2, "lines"),
    plot.title = element_text(hjust = 0.5),
    legend.margin = margin(0, 0, 0, 0, unit = "cm"),
    legend.box.spacing = unit(0.2, "lines"),
    legend.spacing = unit(0.2, "lines")
  )



# Graphs -----
gg_R16 <- gg_cl %+% mus_R16_fmt +
  scale_fill_brewer(palette = "Reds") +
  labs(x = NULL, fill = "Trump\nVoters", title = "2016") +
  theme(
    legend.position = "right",
    legend.key.height = unit(0.1, "lines")
  )

gg_R12 <- gg_R16 %+% mus_R12_fmt +
  theme(axis.text.x = element_blank()) +
  labs(x = NULL, fill = "Romney\nVoters", title = "2012")

gg_D16 <- gg_cl %+% mus_D16_fmt +
  scale_fill_brewer(palette = "Blues") +
  labs(x = NULL, fill = "Clinton\nVoters", title = "2016") +
  theme(
    legend.position = "right",
    legend.key.height = unit(0.1, "lines")
  )

gg_D12 <- gg_D16 %+% mus_D12_fmt +
  theme(axis.text.x = element_blank()) +
  labs(x = NULL, fill = "Obama\nVoters", title = "2012")
#
#
# # Put together -----
gg_R <- gg_R12 + gg_R16 +
  plot_layout(ncol = 1) +
  plot_annotation(
    title = "Among Republican Presidential Voters",
    theme = list(plot.title = element_text(hjust = 0.5, face = "bold"))
  )

gg_D <- gg_D12 + gg_D16 +
  plot_layout(ncol = 1) +
  plot_annotation(
    title = "Among Democratic Presidential Voters",
    theme = list(plot.title = element_text(hjust = 0.5, face = "bold"))
  )


# # Save ------
paper_dir <- "paper/figures"

ggsave(path(paper_dir, "cl_SC-2012-2016_R.pdf"), gg_R, w = 8, h = 4.5)
ggsave(path(paper_dir, "cl_SC-2012-2016_D.pdf"), gg_D, w = 8, h = 4.5)
