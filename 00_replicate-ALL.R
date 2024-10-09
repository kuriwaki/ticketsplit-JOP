# Load packages with exact versions specified in the lockfile
renv::restore()

library(cli)
library(fs)
scripts <- dir_ls(".", regexp = ".R$") |>
  setdiff("00_replicate-ALL.R")

# run all scripts in loop with progress bar
for (s in scripts) {
  cli_progress_step("{.file {s}}", spinner = TRUE)
  source(s)
}
cli_progress_done()
