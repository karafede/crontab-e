

library(threadr)

setwd("/home/federicok/cron_testing")

filenames_csv <- list.files(path = "/home/federicok/cron_testing", pattern = "csv")
file.remove(filenames_csv)
