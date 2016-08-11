

library(threadr)

setwd("C:/cron_testing/AURN/csvs")
# setwd("/home/federicok/cron_testing/AURN")

# filenames_csv <- list.files(path = "/home/federicok/cron_testing/AURN", pattern = "csv")
filenames_csv <- list.files(path = "C:/cron_testing/AURN/csvs", pattern = "csv")
file.remove(filenames_csv)
