
# Load packages
library(dplyr)
library(tidyr)
library(lubridate)
library (devtools)
library (openair)
library(importr)
library(threadr)


#####################################################################################
######---Z_score volatiles (V10, V25) for Chris Connolly----#########################
#####################################################################################


##--- script to find failures when calculationg PM10 and PM2.5 volatile fraction (V10 and V25) according to the z-scores of the V10 and V25 daily means ####

# run this script ONCE a WEEK at ~ 9:05am ###----------------------------------------

# recipients_WALES = "federico.karagulian@ricardo.com pedro.abreu@ricardo.com airqualitymonitoring@ricardo.com"
# recipients_WALES = "federico.karagulian@ricardo.com karafede@hotmail.com"


# remove week before at 9:05 am on Monday
# 5 9 * * 1 Rscript /home/federicok/cron_testing/remove_week_before.R

# run the ImportR script to generate the .csv file with failures
# 6 9 * * 1 Rscript /home/federicok/cron_testing/ImportR_z_score_Pedro.R

# email .csv file present in the folder to recipient

# 8 9 * * 1 mail -s "Volatile failures of the week (Wales z_scores)" -a /home/federicok/cron_testing/*.csv $recipients_WALES < /home/federicok/cron_testing/message_z_score_Wales.txt

# 8 9 * * 1 mail -s "Volatile failures of the week (Wales z_scores)" -a /home/federicok/cron_testing/*.csv federico.karagulian@ricardo.com
# 8 9 * * 1 mail -s "Volatile failures of the week (Wales z_scores)" -a /home/federicok/cron_testing/*.csv pedro.abreu@ricardo.com
# 8 9 * * 1 mail -s "Volatile failures of the week (Wales z_scores)" -a /home/federicok/cron_testing/*.csv airqualitymonitoring@ricardo.com

##############################################################################################################################################


# Set a working directory as in gisdev server
 setwd("/home/federicok/cron_testing")
# setwd("C:/z_scores_volatiles")

info_sites <- search_database("waq", "v10|v25")    ### metadata
info_sites <- subset(info_sites, variable %in% c("v10", "v25")) ### metadata

# Make a site vector to use in importr functions
site_vector <- unique(info_sites$site)

# setup start_date that is one week before the current date
week_before <- Sys.time()-604800  # 60 seconds * 60 minutes * 24 hours * 7 days = 1 week
week_before <- as.character(week_before)
week_before <- str_sub(week_before, start = 1, end = -10) # read only 10 characters (the date)

stats_volatile <- import_stats("waq",site = site_vector, 
                                    variable = c("v10", "v25"),
                                    # start = "2016-01-01",
                                    start = week_before,
                                    # end = "2016-03-31",
                                    statistic = "daily_mean",
                                    extra = TRUE)


# data_volatile <- import_measures("waq", site = site_vector,
#                                      variable = c("v10", "v25"))

# Transform
# To-do: check grouping variables
stats_volatile <- stats_volatile %>%
  group_by(date) %>%      #### only date
  # group_by(date, variable) %>%
  mutate(z_score = scale(value),
         z_score = as.numeric(z_score), 
         z_score_fail = ifelse(abs(z_score) >= 3, FALSE, TRUE))

# Find failures
data_db_failures <- stats_volatile %>%
  filter(!z_score_fail)


# rename colname variable
names(data_db_failures)[names(data_db_failures) == 'variable'] <- 'pollutant'
names(data_db_failures)[names(data_db_failures) == 'unit_name'] <- 'instrument'


if (nrow(data_db_failures) > 0) {
  data_db_failures$z_score_fail <- "FAILED"
  data_db_failures$instrument <- "TEOM-FDMS"
} else if (nrow(data_db_failures) == 0) {
  print("no failures....then no .csv file is going to be written...and sent")}

# file to be sent to Bureau Veritas
data_db_failures_BV <- data_db_failures %>%
  select(site_name,
         pollutant,
         instrument,
         z_score,
         date,
         z_score_fail)

tm <- Sys.time() # current date and time
# tm <- Sys.Date()
DATE <- as.character(tm)
# Remove odd characters
DATE <- gsub(":| |-", "_", DATE)

DATE <- str_sub(DATE, start = 1, end = -10) # read only 10 characters (the date)


if(nrow(data_db_failures_BV) > 0 ) {
  write.csv(data_db_failures_BV, file = paste0("z_scores_",DATE, "_WALES_FAILS.csv"), row.names=FALSE)
} else if (nrow(data_db_failures_BV) == 0) {
  print("no failures....then no .csv file is going to be written...and sent") }



