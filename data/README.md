Data Subfolder
================

This directory contains the datasets listed below.

Here is a brief overview of the datasets:

* .csv files are typically small datasets with metadata and summary statistics specific to a particular script. `by-contest_cand-metadata.csv` gets used the most frequently for candidate-level metadata in South Carolina. Sources: originates from South Carolina Election Commission, my own data collection, and DIME (version 3.1).
* .dta files are also for one-off uses of survey data. Sources: ANES and CCES.
* .parquet files are large datasets and represent the main cast vote record data. `by-votechoice` is stored in long form where one row is a vote choice for a particular office. `by-person-ID` indicates contest IDs for each voters. 
* .rds files are cluster objects estimated from the clusterCVR described in the main text.

List of directories.

    ## .
    ## ├── by-HOU-USH-dist_split.csv
    ## ├── by-contest_cand-metadata.csv
    ## ├── by-person-ID
    ## │   ├── elec=2010-11-02
    ## │   │   └── part-0.parquet
    ## │   ├── elec=2012-11-06
    ## │   │   └── part-0.parquet
    ## │   ├── elec=2014-11-04
    ## │   │   └── part-0.parquet
    ## │   ├── elec=2016-11-08
    ## │   │   └── part-0.parquet
    ## │   └── elec=2018-11-06
    ## │       └── part-0.parquet
    ## ├── by-votechoice
    ## │   ├── elec=2010-11-02
    ## │   │   └── part-0.parquet
    ## │   ├── elec=2012-11-06
    ## │   │   └── part-0.parquet
    ## │   ├── elec=2014-11-04
    ## │   │   └── part-0.parquet
    ## │   ├── elec=2016-11-08
    ## │   │   └── part-0.parquet
    ## │   └── elec=2018-11-06
    ## │       └── part-0.parquet
    ## ├── clusters
    ## │   ├── by-K
    ## │   │   ├── D12_list.rds
    ## │   │   ├── D16_list.rds
    ## │   │   ├── R12_list.rds
    ## │   │   ├── R16_list.rds
    ## │   │   ├── p12_list.rds
    ## │   │   └── p16_list.rds
    ## │   ├── p12_D-subset_k4.rds
    ## │   ├── p12_R-subset_k4.rds
    ## │   ├── p16_D-subset_k4.rds
    ## │   └── p16_R-subset_k4.rds
    ## ├── deluca_quality.csv
    ## ├── hist-elecs_by-office.csv
    ## ├── hist-svy_anes.dta
    ## ├── hist-svy_cces.dta
    ## ├── hist-svy_cd-2020.dta
    ## ├── hist-svy_cd.dta
    ## ├── maricopa
    ## │   └── ballots_wide_party.csv.gz
    ## ├── maryland
    ## │   ├── elec=2016
    ## │   │   └── part-0.parquet
    ## │   ├── elec=2018
    ## │   │   └── part-0.parquet
    ## │   ├── elec=2020
    ## │   │   └── part-0.parquet
    ## │   └── elec=2022
    ## │       └── part-0.parquet
    ## └── palmbeach
    ##     └── herron_lewis_counts.csv.gz
