Replication for ‘Ticket Splitting in a Nationalized Era’
================
Shiro Kuriwaki

This repository is a replication archive for the manuscript, “Ticket
Splitting in a Nationalized Era”.

Both a Dataverse version (<https://doi.org/10.7910/DVN/RXOZEZ>) and a
Github version (<https://github.com/kuriwaki/ticketsplit-JOP>) are
available.

- Dataverse version: has code *and* data, not public until reviewed
- Github: tracks only code, currenlty public.

## How to Replicate

We strongly recommend downloading this entire repository and opening it
as **a RStudio Project**. This will activate the package manager renv
easily.

For convenience, `00_replicate-ALL.R` loops around all R scripts and
executes them indpendently.

## Structure

This repository has the following scripts. The name of the file
indicates the figure / table that it reproduces. For example,
`02_fig-02-B5_toipline.R` indicates that it creates Figure 2 and Figure
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

All scripts default to the project directory “ticketsplit-JOP” for its
working directory.

## Packages and Dependencies

This repository uses R. It uses the renv package
(<https://rstudio.github.io/renv/>) to manage package versions. The
`renv.lock` file encodes all the necessary dependencies. Opening the
project in Rstudio Projects will automatically register the lockfile
(from the `.Rprofile`), and Rstudio Projects will ask if you want to
install missing packages. You can install the missing packages using
`renv::restore()`. See
<https://rstudio.github.io/renv/articles/renv.html> for more help on how
to start this.

For reference, here are the package dependencies across all scripts,
from most used to least.

    ## Finding R package dependencies ... Done!

    ##  [1] "tidyverse"         "scales"            "fs"               
    ##  [4] "ticketsplitJOPpkg" "arrow"             "patchwork"        
    ##  [7] "glue"              "haven"             "fixest"           
    ## [10] "ggtext"            "broom"             "ggrepel"          
    ## [13] "kableExtra"        "lemon"             "marginaleffects"  
    ## [16] "modelsummary"      "renv"              "cli"              
    ## [19] "dplyr"             "gt"                "knitr"            
    ## [22] "rmarkdown"         "stringi"

All packages are on CRAN except `ticketsplitJOPpkg`, which is a bundle
of extra functions specific to this repository. It is available at
<https://github.com/kuriwaki/ticketsplitJOPpkg> and can be installed
with

``` r
remotes::install_github("kuriwaki/ticketsplitJOPpkg")
```
