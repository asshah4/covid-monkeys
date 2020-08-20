# HRV files
analyzed <-
	list.files(
		path = "data/proc_data/",
		recursive = TRUE,
		pattern = ".HRV.*.csv",
		full.names = TRUE
	) %>%
	map_dfr(., read_csv) %>%
	janitor::clean_names() %>%
	separate(pat_id, into = c("monkey", "lead"), sep = "_lead_")

# Quality
removed <-
		list.files(
			path = "data/proc_data/",
			recursive = TRUE,
			pattern = "Removed.*.csv",
			full.names = TRUE
	) %>%
	map_dfr(., read_csv) %>%
	janitor::clean_names() %>%
	separate(pat_id, into = c("monkey", "lead"), sep = "_lead_")

removed %>%
	select(c(monkey, lead, tot_wind, not_analyzed, percent_not_analyzed)) %>%
	write_csv(., "data/monkey-quality-hrv_08-16-20.csv")


# Which are hte best monkeys
removed %>%
	filter(percent_not_analyzed < 20) %>%
	group_by(monkey) %>%
	arrange(percent_not_analyzed) %>%
	slice(1:2) %>%
	print(n = 50)

# Which are the worst monkeys
removed %>%
	filter(percent_not_analyzed > 50) %>%
	group_by(monkey) %>%
	slice(1)


# Trouble monkeys
analyzed %>%
	filter(monkey %in% 1:6) %>%
	group_by(monkey) %>%
	na.omit() %>%
	count()
