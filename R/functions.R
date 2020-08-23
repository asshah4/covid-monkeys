# Intake data

get_ids <- function(file) {
	read_csv(file) %>%
		group_by(name) %>%
		mutate(visit = row_number())
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

# Tidy data

tidy_data <- function(analyzed) {
}

# Write data

write_data <- function(analyzed) {
		analyzed %>%
		select(session, name, visit, lead, n_nmean, sdnn, rmssd, pnn50, hf, lf, vlf, ulf, lfhf, ttlpwr, ac, dc, samp_en, ap_en) %>%
		group_by(session, name) %>%
		mutate(
			session = factor(session),
			visit = factor(visit)
		) %>%
		summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))
}
