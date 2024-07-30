suppressPackageStartupMessages({
  library(tidyverse)
  library(patchwork)
})

# Data estimates
fit12_obj <- read_rds("data/clusters/by-K/p12_list.rds")
fit12_d_obj <- read_rds("data/clusters/by-K/D12_list.rds")
fit12_r_obj <- read_rds("data/clusters/by-K/R12_list.rds")
fit16_obj <- read_rds("data/clusters/by-K/p16_list.rds")
fit16_d_obj <- read_rds("data/clusters/by-K/D16_list.rds")
fit16_r_obj <- read_rds("data/clusters/by-K/R16_list.rds")

# convenience wrapper
ll_df <- function(obj) {
  map_dfr(
    .x = obj,
    .f = \(.x) {
      n_voters <- .x$aux$N

      tibble(
        k = NROW(.x$ests$mu[, , 1]),
        N = n_voters,
        loglik = .x$loglik_runs,
        BIC = 2 * loglik - length(.x$ests$params) * log(n_voters)
      )
    }
  )
}

l12_a <- ll_df(fit12_obj)
l12_d <- ll_df(fit12_d_obj)
l12_r <- ll_df(fit12_r_obj)

l16_a <- ll_df(fit16_obj)
l16_d <- ll_df(fit16_d_obj)
l16_r <- ll_df(fit16_r_obj)

# Main graph ----
gg_elb <- l12_a |>
  ggplot(aes(x = as_factor(k), BIC / N, group = 1)) +
  geom_point() +
  geom_line() +
  coord_cartesian() +
  theme_classic() +
  labs(
    x = "Number of Clusters",
    y = "BIC Fit (per Voter)"
  ) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

gg12_A <- gg_elb + geom_vline(xintercept = 5, linetype = "dotted") + labs(title = "All 2012 Voters")
gg12_D <- gg_elb %+% l12_d + geom_vline(xintercept = 2, linetype = "dotted") + labs(title = "Obama Voters", y = NULL)
gg12_R <- gg_elb %+% l12_r + geom_vline(xintercept = 3, linetype = "dotted") + labs(title = "Romney Voters", y = NULL)

gg16_A <- gg_elb + geom_vline(xintercept = 4, linetype = "dotted") + labs(title = "All 2016 Voters")
gg16_D <- gg_elb %+% l16_d + geom_vline(xintercept = 3, linetype = "dotted") + labs(title = "Clinton Voters", y = NULL)
gg16_R <- gg_elb %+% l16_r + geom_vline(xintercept = 3, linetype = "dotted") + labs(title = "Trump Voters", y = NULL)


# Put together ----
gg12_A + gg12_D + gg12_R
ggsave("paper/figures/elbow-plot_clusters_2012.pdf", w = 6, h = 2.3)

gg16_A + gg16_D + gg16_R
ggsave("paper/figures/elbow-plot_clusters_2016.pdf", w = 6, h = 2.3)
