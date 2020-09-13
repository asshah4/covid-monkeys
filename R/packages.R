# Load all your packages before calling make().

# Setup / basics
library(drake)
library(tidyverse)
library(tidymodels)

# Production
library(kableExtra)
library(stargazer)
library(gridExtra)
library(ggthemes)
library(gt)
library(gtsummary)

# Statistical tools
library(Hmisc)
library(lme4)
library(compareGroups)
library(mediation)

# Tidying
library(magrittr)
library(janitor)
library(readxl)
library(ggdag)
library(dagitty)
library(data.table)

# Personal
library(card)

# Conflicts
library(conflicted)
conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")
conflict_prefer("summarize", "dplyr")

