suppressPackageStartupMessages({
  library(tidyverse)
  library(ggrepel)
  library(scales)
  library(fs)
  library(glue)
})

#' extract and save
print_row <- function(office_use,
                      filename,
                      dir = "paper/tables/historical",
                      tbl = office_bin) {
  office_tbl <- tbl |>
    filter(office == office_use)
  tot_n <- sum(office_tbl$n)

  wtbl <- tbl |>
    pivot_wider(
      id_cols = office,
      names_from = yr_bin,
      values_from = mar_R
    )

  wtbl_i <- wtbl |>
    filter(office == office_use) |>
    select(-office)

  # text format
  pad2 <- \(txt) str_pad(txt, width = 2, side = "left", pad = "0")

  wtbl_i |>
    mutate(
      across(
        .cols = everything(),
        .fns = \(.x) str_c(ifelse(.x > 0, "R", "D"), pad2(number(abs(.x), scale = 100, accuracy = 1, style_positive = "plus")))
      )
    ) |>
    mutate(n = number(tot_n, accuracy = 1, big.mark = ","))
}

# Data ----
office_bin <- read_csv("data/hist-elecs_by-office.csv",
  col_types = "ccidddcc"
)

# Tables ---
print_row("President")
print_row("Governor")

# Plot ----
plot_D <- office_bin |>
  filter(!office %in% c("Governor", "President"))

office_counts <- office_bin |>
  group_by(office) |>
  summarize(total_n = format(sum(n), big.mark = ","))

beg_D <- filter(plot_D, yr_bin %in% "1980-1982") |>
  mutate(beg_lab = glue("{office}: {fpct_D}"))

end_D <- filter(plot_D, yr_bin %in% "2016-2018") |>
  inner_join(office_counts, by = "office") |>
  mutate(end_lab = glue("{fpct_D} (n = {total_n})"))

plot_D |>
  ggplot(aes(yr_bin, pct_D, group = office, linetype = office)) +
  geom_line() +
  geom_text_repel(data = beg_D, aes(label = beg_lab), hjust = 1, nudge_x = -1.5, direction = "y", segment.color = "gray") +
  geom_text_repel(data = end_D, aes(label = end_lab), hjust = 0, nudge_x = 2, direction = "y", segment.color = "gray") +
  geom_point() +
  scale_color_grey() +
  expand_limits(x = c(-3, 12.5)) +
  theme_classic() +
  guides(linetype = "none") +
  theme(
    axis.line = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    plot.margin = margin(0, 0, 0, 0, "in")
  )

ggsave("paper/figures/historical_D-share.pdf", h = 3, w = 8)
