# HRV files
analyzed <-
	list.files(
		path = "data/proc_data/",
		recursive = TRUE,
		pattern = ".HRV.*.csv",
		full.names = TRUE
	) %>%
	map_dfr(., read_csv) %>%
	janitor::clean_names()

# Quality
removed <-
		list.files(
			path = "data/proc_data/",
			recursive = TRUE,
			pattern = "Removed.*.csv",
			full.names = TRUE
	) %>%
	map_dfr(., read_csv) %>%
	janitor::clean_names()

removed %>%
	select(c(pat_id, tot_wind, not_analyzed, percent_not_analyzed)) %>%
	write_csv(., "data/monkey_quality_hrv.csv")

