library(rvest)
library(dplyr)
library(readr)

url <- "https://www.eea.europa.eu/en/about/careers/vacancies"

page <- read_html(url)

jobs <- page %>%
  html_elements("a") %>%
  html_text(trim = TRUE) %>%
  .[grepl("vacanc|position|job", ., ignore.case = TRUE)] %>%
  unique()

# Load previous jobs
file_path <- "jobs_seen.csv"

if (file.exists(file_path)) {
  old_jobs <- read_csv(file_path, show_col_types = FALSE)$jobs
} else {
  old_jobs <- character()
}

new_jobs <- setdiff(jobs, old_jobs)

# Optional filtering
keywords <- c("data", "analysis", "research")

filtered_jobs <- new_jobs[
  sapply(new_jobs, function(x)
    any(grepl(paste(keywords, collapse="|"), x, ignore.case=TRUE))
  )
]

if (length(filtered_jobs) > 0) {
  writeLines(filtered_jobs, "new_jobs.txt")
} else {
  writeLines("No new relevant jobs", "new_jobs.txt")
}

# Save updated jobs list
write_csv(data.frame(jobs = jobs), file_path)
