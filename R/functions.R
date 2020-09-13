# Intake data

get_ids <- function(file) {

		# COVID infection occurred on day 0; for those in treatment group it started at day 2 post infection.  Last data point is day 10
		# COVID: 06_112, 5_215, RQv9, RHz12
		# COVID+treatment: Rat11, RLf10, 7_141, RVf12
		# I can also tell you that RQv9 had the most sever clinical phenotype with overt pneumonia
	tx <-
		tribble(
			~names, ~treatment,
			"06_112", 0,
			"5_215", 0,
			"rqv9", 0,
			"rhz12", 0,
			"rat11", 1,
			"rlf10", 1,
			"7_141", 1,
			"rvf12", 1,
		)

	# Combined data set
	read_csv(file) %>%
		group_by(names) %>%
		mutate(names = tolower(names)) %>%
		left_join(., tx, by = "names")
}

get_analyzed <- function(ids) {
	list.files(
		path = "data/proc_data/",
		recursive = TRUE,
		pattern = ".HRV.*.csv",
		full.names = TRUE
	) %>%
		map_dfr(., read_csv) %>%
		janitor::clean_names() %>%
		separate(pat_id, into = c("session", "lead"), sep = "_lead_") %>%
		mutate(session = as.numeric(session)) %>%
		left_join(ids, ., by = "session")
}

get_removed <- function(ids) {
	list.files(
			path = "data/proc_data/",
			recursive = TRUE,
			pattern = "Removed.*.csv",
			full.names = TRUE
		) %>%
		map_dfr(., read_csv) %>%
		janitor::clean_names() %>%
		separate(pat_id, into = c("session", "lead"), sep = "_lead_") %>%
		mutate(session = as.numeric(session)) %>%
		left_join(ids, ., by = "session")
}

# Write data

write_data <- function(analyzed) {
		analyzed %>%
		select(session, names, visit, treatment, lead, n_nmean, sdnn, rmssd, pnn50, hf, lf, vlf, ulf, lfhf, ttlpwr, ac, dc, samp_en, ap_en) %>%
		group_by(session, names) %>%
		mutate(
			session = factor(session),
			visit = factor(visit)
		) %>%
		summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))
}
