

library(threadr)

# setwd("C:/cron_testing")
setwd("/home/federicok/cron_testing/AURN")

day_before <- Sys.time()-86400  # 60 seconds * 60 minutes * 24 hours = 1 day
day_before <- as.character(day_before)
day_before <- str_sub(day_before, start = 1, end = -10) # read only 10 characters (the date)
day_before <- gsub(":| |-", "_", day_before)

# remove the previous .csv file (1 day before)
if (file.exists (paste0("z_scores_",day_before,"_AURN_FAILS.csv") )) file.remove( paste0("z_scores_",day_before,"_AURN_FAILS.csv"))
