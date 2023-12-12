rm(list = ls())

library(brms)
library(cowplot)
library(dplyr)
library(forcats)
library(ggdist)
library(ggplot2)
library(glue)
library(readr)
library(readxl)
library(stringr)
library(tidyr)

theme_set(theme_cowplot())

source("r/functions.R")

# Constants for estimating c_ad / c_ab
delta_0 = -9.10
a = 4.4

raw_data_file = "raw-data/askanbayeva-etal-data.xlsx"
