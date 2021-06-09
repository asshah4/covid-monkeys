library(targets)
library(tarchetypes)

library(targets)
library(tarchetypes)

# Functions
source("R/options.R")
source("R/intake-functions.R")
source("R/tidy-functions.R")

# Set target-specific options such as packages.
tar_option_set(
	packages = c(
		# Personal
		"card", "aim",
		# Tidyverse/models
		"tidyverse", "tidymodels", "readxl", "haven", "janitor",
		# Tables / figures
		"gt", "gtsummary", "labelled",
		# Stats
		"lme4", "Hmisc"
	),
	error = "workspace"
)

# Define targets
targets <- list(

	# Files
	tar_target(
		file_ids,
		"../../data/covid-monkeys/ids-march-2021.csv",
		format = "file"
	),
	tar_target(
		folder_path,
		"../../data/covid-monkeys/proc_data/second_analysis/",
		format = "file"
	),

	# Intake
	tar_target(ids, get_ids(file_ids)),
	tar_target(raw_data, get_analyzed(folder_path, ids)),

	# Tidy
	tar_target(proc_data, tidy_data(raw_data)),
	tar_target(summary_data, write_data(proc_data), format = "file")

)
