# amphiwaxy

This repository contains source code associated with the manuscript:

Amphistomy: stomata patterning inferred from 13C content and leaf–side specific deposition of epicuticular wax. In review at *Annals of Botany*.

## Authors

Balzhan Askanbayeva $^1$, Jitka Janová $^1$, Jiří Kubásek $^1$, Lukas Schreiber $^2$, Christopher D. Muir $^3$, Jiří Šantrůček $^1$

$^1$ Faculty of Science, Department of Experimental Plant Biology, University of South Bohemia, Branišovská 31, 370 05 České Budějovice, Czech Republic

$^2$ Institute of Cellular and Molecular Botany, University of Bonn, Kirschallee 1, 53115 Bonn, Germany

$^3$ Department of Botany, University of Wisconsin, 143 Lincoln Drive Madison, Wisconsin, USA 53711

## Contents

This repository has the following file folders:

- `figures`: figures generated from *R* code
- `objects`: saved objects generated from *R* code
- `processed-data`: processed data generated from *R* code
- `r`: *R* scripts for all data processing and analysis
- `raw-data`: raw data files (not included in public repository)

## Prerequisites:

To run code and render manuscript:

- [*R*](https://cran.r-project.org/) version >4.3.0 and [*RStudio*](https://www.posit.co/) (recommended)

Before running scripts, you'll need to install the following *R* packages:

```
source("r/install-packages.R")
```

To fit **brms** model, set up [**cmdstanr**](https://mc-stan.org/cmdstanr/).

## Downloading data and code 

1. Download or clone this repository to your machine.

```
git clone git@github.com:cdmuir/amphiwaxy.git
```

2. Open `amphiwaxy.Rproj` in [RStudio](https://www.posit.co/)

3. Run all code.

```
# Won't work because raw data files are not on the public repository
# source("01_process-d13C.R")
# source("02_process-stomata.R")

# Start from here using processed data files
source("03_join-dC13-asl.R")
source("04_fit-dC13-asl.R")
source("05_fit-dCi-asl.R")
source("06_plot-stomata.R")
source("07_plot-dC13-asl.R")
source("08_plot-dCi-asl.R")
source("09_summarize-d13c-asl.R")
```