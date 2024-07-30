suppressPackageStartupMessages({
  library(tidyverse)
  library(arrow)
  library(patchwork)
  library(scales)
  library(ggtext)
  library(glue)
  library(ticketsplitJOPpkg)
})


#' Calculate `props` for each office
calc_splits <- function(dat) {
  bind_rows(
    frac_by_top("USS", dat |> filter(str_detect(elec, "(2012|2016)"))),
    frac_by_top("USH", dat),
    frac_by_top("GOV", dat),
    frac_by_top("LGV", dat),
    frac_by_top("ATG", dat),
    frac_by_top("SOS", dat),
    frac_by_top("SSI", dat),
    frac_by_top("SEN", dat),
    frac_by_top("HOU", dat),
    frac_by_top("JPR", dat),
    frac_by_top("SHF", dat),
    frac_by_top("CLR", dat),
    frac_by_top("AUD", dat),
    frac_by_top("CCD", dat)
  ) |>
    mutate(
      office_raw = office,
      office = fct_inorder(ticketsplitJOPpkg::recode_abbrv(office))
    )
}

#' Make graphic from output of `calc_splits`
main_plot <- function(tbl, lbl1 = "Top-of-ticket candidate", lbl2 = "<br>Among **both** voters") {
  # formatting
  splits_lbl <- tbl |>
    filter(office != "U.S. Senate") |>
    mutate(
      frac_lbl = scales::percent(frac, accuracy = 1),
      frac_lbl = replace(frac_lbl, type != "Split", NA)
    )

  # main
  splits_total <- tbl |>
    filter(office != "U.S. Senate") |>
    summarize(
      frac = weighted.mean(frac, tot_n), tot_n = sum(tot_n),
      .by = c(office, type)
    ) |>
    mutate(
      frac_lbl = scales::percent(frac, accuracy = 1),
      frac_lbl = replace(frac_lbl, type != "Split", NA)
    )

  # base plot
  gg_base <- filter(splits_lbl, top_party2 == 1) |>
    ggplot(aes(
      y = fct_rev(office),
      x = frac,
      fill = fct_relevel(type, "Straight", "Roll-off", "Other", "Split")
    )) +
    geom_col() +
    geom_text(aes(label = frac_lbl),
      color = "white",
      position = position_stack(vjust = 0),
      hjust = 0,
      family = "mono",
      na.rm = TRUE
    ) +
    theme_bw() +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.text.x = element_text(color = "black", size = 9),
      axis.text.y = element_text(color = "black", size = 10),
      strip.text = element_text(color = "black", size = 10),
      legend.position = "bottom",
      legend.box.spacing = unit(0.2, "lines"),
      legend.spacing = unit(0.2, "lines"),
      legend.key.height = unit(0.1, "lines"),
      plot.title = element_markdown(hjust = 0.5, size = 14)
    ) +
    scale_x_continuous(expand = c(0, 0)) +
    labs(x = "Proportion voting", y = "", fill = NULL)

  # colors

  gg_R <- gg_base +
    scale_fill_brewer(
      palette = "Reds",
      guide = guide_legend(reverse = TRUE, nrow = 2, byrow = TRUE)
    ) +
    labs(title = glue("Among voters of **Republican**<br>{lbl1}"))

  gg_D <- gg_base %+% filter(splits_lbl, top_party2 == -1) +
    scale_fill_brewer(
      palette = "Blues",
      guide = guide_legend(reverse = TRUE, nrow = 2, byrow = TRUE)
    ) +
    theme(axis.text.y = element_blank()) +
    labs(title = glue("Among voters of **Democratic**<br>{lbl1}"))

  gg_all <- gg_base %+% splits_total +
    scale_fill_brewer(
      palette = "Greys",
      guide = guide_legend(reverse = TRUE, nrow = 2, byrow = TRUE)
    ) +
    theme(axis.text.y = element_blank()) +
    labs(title = glue("{lbl2}"))

  # patchwork all together
  gg_R + plot_spacer() + gg_D + plot_spacer() + gg_all +
    plot_layout(widths = c(1, 0.01, 1, 0.01, 1), nrow = 1)
}

# Main dataset ----
splits <- open_dataset("data/by-votechoice/") |>
  calc_splits()

## alternative definition of top of the ticket
splits_alt <- open_dataset("data/by-votechoice/") |>
  mutate(top_party2 = top_party2_alt) |>
  calc_splits() |>
  filter(str_detect(office_raw, "(GOV|USS|ATG|SOS|LGV)", negate = TRUE))

# Graph ------
main_plot(splits)
ggsave("paper/figures/rates_by_top_barplot.pdf", w = 10, h = 4.1)

main_plot(splits_alt)
ggsave("paper/figures/rates_by_top_barplot_alt-top2.pdf", w = 10, h = 3.6)
