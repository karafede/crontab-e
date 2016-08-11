

library(threadr)

# setwd("C:/z_scores_volatiles")
setwd("/home/federicok/cron_testing")

week_before <- Sys.time()-604800  # 60 seconds * 60 minutes * 24 hours * 7 days = 1 week
week_before <- as.character(week_before)
week_before <- str_sub(week_before, start = 1, end = -10) # read only 10 characters (the date)
week_before <- gsub(":| |-", "_", week_before)

# remove the previous .csv file (1 week before)
if (file.exists (paste0("z_scores_",week_before,"_FAILS.csv") )) file.remove( paste0("z_scores_",week_before,"_FAILS.csv"))
