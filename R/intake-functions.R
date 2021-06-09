# Get IDS
get_ids <- function(file_ids) {

	# Draw in ids
	ids <-
		read_csv(file_ids) %>%
		mutate(names = tolower(names))

	# Return
	ids
}

# Get files
get_analyzed <- function(folder_path, ids) {

	# Get data paths
	df <- list.files(
		path = folder_path,
		recursive = TRUE,
		pattern = ".HRV.*.csv",
		full.names = TRUE
	) %>%
		map_dfr(., read_csv) %>%
		clean_names() %>%
		separate(pat_id, into = c("session", "lead"), sep = "_lead_") %>%
		mutate(session = as.numeric(session)) %>%
		left_join(ids, ., by = "session") %>%
		mutate(
			hf = log(hf),
			lf = log(lf),
			rmssd = log(rmssd)
		)

	# Return
	df

}
