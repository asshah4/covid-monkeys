# Tidy data
tidy_data <- function(raw_data) {

	# Summarize by session and group
	df <- raw_data %>%
		mutate(
			session = factor(session),
			visit = factor(visit)
		) %>%
		group_by(names, session, visit, lead) %>%
		summarise(across(c(n_nmean, sdnn:pnn50, ulf:ttlpwr, ac:ap_en), ~ mean(.x, na.rm = TRUE)))

	# Return
	df

}

# Write out data
write_data <- function(proc_data) {

	# Summarized data to write out
	write_csv(proc_data, "./products/summary_data.csv")
	return("./products/summary_data.csv")

}
