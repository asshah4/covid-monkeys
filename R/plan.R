plan <- drake_plan(

	# Intake
	ids = get_ids(file_in("data/ids.csv")),
	analyzed = get_analyzed(ids),
	removed = get_removed(ids),

	# Tidy

	# Report
	prelim = if(TRUE) {rmarkdown::render(
		knitr_in("R/explore.rmd"),
		output_file = file_out("products/draft-findings.pdf"),
		output_dir = "products"
	)}

)
