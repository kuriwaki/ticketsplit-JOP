suppressPackageStartupMessages({
  library(tidyverse)
  library(haven)
  library(kableExtra)
  library(ticketsplitJOPpkg)
  library(scales)
})

# Data ------
by_contest <- read_csv("data/by-contest_cand-metadata.csv",
  show_col_types = FALSE
)

m_df <- by_contest |>
  mutate(
    plot_type = recode(
      office,
      GOV = "Top of the Ticket",
      PRS = "Top of the Ticket",
      LGV = "Statewide Executive",
      ATG = "Statewide Executive",
      SOS = "Statewide Executive",
      SSI = "Statewide Executive",
      USS = "Congressional",
      USH = "Congressional",
      USSEN1 = "Congressional",
      USSEN2 = "Congressional",
      .default = "State and Local"
    ),
    plot_type = fct_relevel(
      plot_type,
      "Top of the Ticket",
      "Statewide Executive",
      "Congressional"
    )
  ) |>
  relocate(elec:dist)

# Plot ------
m_df |>
  filter(!is.na(hits_D), !is.na(hits_R)) |> 
  ggplot(aes(x = (hits_D + 1), y = (hits_R + 1))) +
  facet_wrap(~plot_type, nrow = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray") +
  geom_point(size = 0.2) +
  coord_equal() +
  scale_x_log10(limits = c(1, 1e5), breaks = c(1, 1e1, 1e2, 1e3, 1e4), labels = comma) +
  scale_y_log10(limits = c(1, 1e5), breaks = c(1, 1e1, 1e2, 1e3, 1e4), labels = comma) +
  theme_classic() +
  guides(color = "none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(
    x = "Democratic Candidate Mentions",
    y = "Republican Candidate Mentions",
    caption = "Each point is a contested race. Plots shown on log10 scale."
  )
ggsave("paper/figures/mentions_descriptive.pdf", w = 7, h = 3.5)


# Table Examples ------
print_top_n <- function(subset, tbl = m_df, n = 5) {
  m_df |>
    filter(plot_type == subset) |>
    rowwise() |>
    mutate(max_hit = max(hits_R, hits_D)) |>
    ungroup() |>
    arrange(desc(max_hit)) |>
    slice(1:n) |>
    transmute(
      elec = str_sub(elec, 1, 4),
      office = recode_abbrv(office),
      cand_D,
      hits_D = formatC(hits_D, format = "d", big.mark = ","),
      cand_R,
      hits_R = formatC(hits_R, format = "d", big.mark = ",")
    ) |>
    mutate(cand_D = recode(cand_D, `William Alexander McCoy III` = "William McCoy")) |>
    mutate(office = recode(office, `County\nSheriff` = "Sheriff")) |>
    mutate(office = recode(office, `Secretary of State` = "Sec of State")) |>
    mutate(office = recode(office, `US Senate Special` = "US Senate")) |>
    mutate(office = recode(office, `Attorney General` = "Attorney Gen")) |>
    mutate(office = recode(office, `AUD` = "Auditor")) |>
    kable(
      col.names = c("Year", "Office", "Name", "#", "Name", "#"),
      align = c("l", "l", "l", "r", "l", "r"),
      linesep = c(rep("", n)),
      booktab = TRUE,
      format = "latex"
    ) |>
    add_header_above(c(" ", " ", "Democrat" = 2, "Republican" = 2)) |>
    column_spec(1, "1.0cm") |>
    column_spec(2, "2.4cm") |>
    column_spec(c(3, 5), "4.0cm") |>
    column_spec(c(4, 6), "1.0cm")
  # write_lines(glue("paper/tables/mentions_top5/{str_replace_all(str_to_lower(subset), '[[:space:]]', '-')}.tex"))
}

print_top_n("Top of the Ticket")
print_top_n("Congressional", n = 10)
print_top_n("State and Local", n = 10)

# Summary statistics ----

sum_stats <- function(var, tbl = by_contest) {
  var <- enquo(var)

  tbl_stat <- tbl |>
    filter(office %in% c("USH", "HOU", "SEN", "SHF", "JPR", "CCD")) |>
    mutate(office = fct_relevel(office, "USH", "HOU", "SEN", "SHF", "JPR", "CCD")) |>
    group_by(office) |>
    summarize(
      avg = mean(!!var, na.rm = TRUE),
      q10 = quantile(!!var, 0.10, na.rm = TRUE),
      q50 = quantile(!!var, 0.50, na.rm = TRUE),
      q90 = quantile(!!var, 0.90, na.rm = TRUE),
      sdv = sd(!!var, na.rm = TRUE),
      eavg = exp(mean(!!var, na.rm = TRUE)),
      eq10 = exp(quantile(!!var, 0.10, na.rm = TRUE)),
      eq50 = exp(quantile(!!var, 0.50, na.rm = TRUE)),
      eq90 = exp(quantile(!!var, 0.90, na.rm = TRUE)),
      n = n()
    ) |>
    mutate(
      office = str_replace(recode_abbrv(office), "\\n", " "),
      office = str_replace(office, "JPR", "Probate Judge")
    ) |>
    kable(
      format = "latex",
      col.names = c(
        "Office",
        "Mean", "10th", "50th", "90th", "S.D.",
        "Mean", "10th", "50th", "90th",
        "N"
      ),
      digits = 2,
      linesep = "",
      booktab = TRUE
    ) |>
    add_header_above(c(" ", "Log Values" = 5, "Exponentiated" = 4, " "))
}


paper_dir <- "paper/tables"
sum_stats(Rmoneyadv) |> write_lines(path(paper_dir, "money.tex"))
sum_stats(Rnewsadv)  |> write_lines(path(paper_dir, "news.tex"))
