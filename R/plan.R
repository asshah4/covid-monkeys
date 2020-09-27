plan <- drake_plan(

	# Intake
	ids = get_ids(file_in("data/ids.csv")),
	analyzed = get_analyzed(ids),
	removed = get_removed(ids),

	# Write out data
	write_out_data =
		write_data(analyzed) %>%
		write_csv(
			.,
			path = file_out("data/results.csv")
		),

	# Report
	prelim = if(FALSE) {rmarkdown::render(
		knitr_in("R/explore.rmd"),
		output_file = file_out("products/draft-findings.pdf"),
		output_dir = "products"
	)},

	draft = if(TRUE) {rmarkdown::render(
		knitr_in("R/html-explore.rmd"),
		output_file = file_out("products/slides.html"),
		output_dir = "products"
	)},

)
