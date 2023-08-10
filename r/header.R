rm(list = ls())

library(brms)
library(cowplot)
library(dplyr)
library(ggplot2)
library(readr)
library(readxl)
library(stringr)
library(tidyr)

theme_set(theme_cowplot())

source("r/functions.R")

# Constants for estimating c_ad / c_ab
delta_0 = -9.10
a = 4.4
