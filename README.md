Replication for ‘Ticket Splitting in a Nationalized Era’
================
Shiro Kuriwaki

This repository is a replication archive for the manuscript, “Ticket
Splitting in a Nationalized Era”.

Both a Dataverse version and a [Github
version](https://github.com/kuriwaki/ticketsplit-JOP) are available.

## How to Replicate

I strongly recommend downloading this entire repository and opening it
as **a [RStudio](https://posit.co/download/rstudio-desktop) Project**.
This will activate the package manager **renv** easily. Specifically:

1.  In RStudio, create a new Rstudio project.
    1.  If you downloaded the packet from Dataverse, you can open the
        `ticketsplit-JOP.Rproj` file.
    2.  If you are starting from Github, start from your local RStudio
        and create a [new
        project](https://support.posit.co/hc/en-us/articles/200526207-Using-RStudio-Projects)
        with the option of `Create from Version Control` \> `Git`, and
        this this URL <https://github.com/kuriwaki/ticketsplit-JOP>.
2.  A new Project should open. Run `renv::restore()` to download the
    necessary packages with their versions in one step. When prompted if
    you want to proceed with installing packages, enter “Y” (for yes) on
    the R console.
3.  Then, inside the Rstudio and renv environment, replicators can run
    the master script `00_replicate-ALL.R` or run each R script.

See the “package and dependencies” section for more on replication
environment.

## Project Structure

This repository has the following scripts. The name of the file
indicates the figure / table that it reproduces. For example,
`02_fig-02-B5_topline.R` indicates that it creates Figure 2 and Figure
B5.

    ## 00_replicate-ALL.R                 01_fig-01_historical-ticketsplit.R 
    ## 02_fig-02-B5_topline.R             03_fig-03_vis-clusterCVR.R         
    ## 04_fig-04_valence-reg.R            05_fig-05_deluca.R                 
    ## 06_fig-06_DIME-positioning.R       07_fig-A2_tab-A2_news-mention.R    
    ## 08_tab-A3_SC-historical.R          09_tab-A4_samplesizes.R            
    ## 10_fig-B1_vticket-SC.R             10_fig-B2_vticket-MD.R             
    ## 10_fig-B3_vticket-AZ.R             10_fig-B4_vticket-FL.R             
    ## 11_tab-B1_by-person-stats.R        12_tab-B2_crosstab_inc.R           
    ## 13_fig-B6_viz-logit-fit.R          14_tab-B3_multivariate.R           
    ## 15_fig-B7_uncontested.R            16_tab-B4_overtime-trend.R         
    ## 17_fig-C1_elbow-plots.R

All scripts default to the project directory (e.g., “ticketsplit-JOP”,
or where the `.Rproj` file is located) as its working directory.

## Datasets

The data in this archive include standard `csv` files, Stata `dta` files
(which should be read in with `.dta`) and parquet files (`.parquet`).
The parquet files are compact storage formats for large datasets and
allows the models to be run quickly. It can be loaded with the `arrow`
package using the `open_dataset()` function. For a reference, see
<https://r4ds.hadley.nz/arrow>.

## Packages and Dependencies (renv)

This repository uses R. It uses the [renv
package](https://rstudio.github.io/renv) to manage package versions, so
that there are no internal inconsistencies on your computer The
`renv.lock` file encodes all the necessary dependencies. Opening the
project in Rstudio Projects will automatically register the lockfile
(from the `.Rprofile`), and Rstudio Projects will ask if you want to
install missing packages. You can install the missing packages using
`renv::restore()`. See
<https://rstudio.github.io/renv/articles/renv.html> for more help on how
to start this.

For reference, here are the package dependencies across all scripts,
from most used to least (renv will instlal these for you).

    ## Finding R package dependencies ... Done!
    ## c("tidyverse", "scales", "fs", "ticketsplitJOPpkg", "arrow", 
    ## "patchwork", "glue", "haven", "fixest", "ggtext", "broom", "ggrepel", 
    ## "kableExtra", "lemon", "marginaleffects", "modelsummary", "renv", 
    ## "rmarkdown", "cli", "dplyr", "gt", "knitr", "stringi")

All packages are on CRAN except `ticketsplitJOPpkg`, which is a bundle
of extra functions specific to this repository. It is available at
<https://github.com/kuriwaki/ticketsplitJOPpkg>. `renv` will install
this for you, but it can also be manually installed with

``` r
remotes::install_github("kuriwaki/ticketsplitJOPpkg")
```
