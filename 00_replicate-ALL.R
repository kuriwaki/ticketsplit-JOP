library(cli)
library(fs)

scripts <- dir_ls(".", regexp = ".R$") |> 
  setdiff("00_replicate-ALL.R")


for (s in scripts[7:20]) {
  cli_progress_step("{.file {s}}", spinner = TRUE)
  source(s)
}
cli_progress_done()


# Move
projdir_to <- "~/Projects/ticketsplit-JOP/"

file_delete(dir_ls(projdir_to, regexp = ".R", recurse = FALSE))
file_delete(dir_ls(path(projdir_to, "data"), recurse = TRUE))

# move scripts
scripts <- dir_ls("analyze-JOP/", regexp = ".R$")

file_copy(scripts, new_path = projdir_to, overwrite = TRUE) # scripts
dir_copy("data", new_path = path(projdir_to, "data"), overwrite = TRUE) # data
