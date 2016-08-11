
# load packages

library(dplyr)
library(tidyr)
library(lubridate)
library(devtools)
library(openair)
library(importr)
library(threadr)

#####################################################################################
######----Z_score volatiles (V10, V25) for Brian Stacey----##########################
#####################################################################################


# run this script ONCE A DAY at ~ 6am ####-------------------------------------------

# remove day before at 5:55 am every day
# 55 5 * * * Rscript /home/federicok/cron_testing/AURN/remove_day_before.R

# run the ImportR script to generate the .csv file with failures
# 56 5 * * * Rscript /home/federicok/cron_testing/AURN/ImportR_z_score_Brian.R

# email .csv file present in the folder to recipient

# recipients_AURN = "federico.karagulian@ricardo.com karafede@hotmail.com"
# recipients_AURN = "federico.karagulian@ricardo.com pedro.abreu@ricardo.com brian.stacey@ricardo.com"
# body_file = "/home/federicok/cron_testing/AURN/prova_text.txt"


# 0 6 * * * mail -s "Volatile failures of the day (AURN z_scores)" -a /home/federicok/cron_testing/AURN/*.csv $recipients_AURN < /home/federicok/cron_testing/AURN/message_z_score.txt


# 0 15 * * * echo some text to display | mail -s "Volatile failures of the day (AURN z_scores)" -a /home/federicok/cron_testing/AURN/*.csv federico.karagulian@ricardo.com


# 18 14 * * * mail -s "Volatile failures of the day (AURN z_scores)" -a /home/federicok/cron_testing/AURN/*.csv "$recipients"  <<< "Attached follows the list of sites that present the latest 24h outliers to the Volatile (V10 and V2.5) AURN national z_score analysis. A Z_score of +/-3 is 3 standard deviation from the mean or 99.5 percent confidence in the result. Any outlier to this value could be used as a screening tool for identifying possible instrumental issues of a site measuring Particle matter."

 

#######################################################################################################################



# Set a working directory as in gisdev server
setwd("/home/federicok/cron_testing/AURN")
# setwd("C:/cron_testing/AURN")

# Helpers
# print_database_names()
# print_statistic_types()

info_sites <- search_database("archive", "v10|v25")    ### metadata on volatile PM10 and PM2.5
info_sites <- subset(info_sites, variable %in% c("v10", "v25")) ### metadata

# Make a site vector to use in importr functions
site_vector <- unique(info_sites$site)

# setup start_date that is one week before the current date
# week_before <- Sys.time()-604800  # 60 seconds * 60 minutes * 24 hours * 7 days = 1 week
day_before <- Sys.time()-86400  # 60 seconds * 60 minutes * 24 hours = 1 day
day_before <- as.character(day_before)
day_before <- str_sub(day_before, start = 1, end = -10) # read only 10 characters (the date)

stats_volatile <- import_stats("archive",site = site_vector, 
                                    variable = c("v10", "v25"),
                                    #start = "2016-07-10",
                                    start = day_before,
                                    # end = "2016-03-31",
                                    statistic = "daily_mean",
                                    extra = TRUE)


# data_volatile <- import_measures("archive", site = site_vector,
#                                      variable = c("v10", "v25"))

# Transform ALL data (calclualte the z-score or normalise the data)
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


##########################################################################################
# data_FALSE <- read.csv("z_scores_2016_07_22_AURN_FAILS.csv")
# data_db_failures <- data_FALSE
##########################################################################################

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
  write.csv(data_db_failures_BV, file = paste0("z_scores_",DATE, "_AURN_FAILS.csv"), row.names=FALSE)
} else if (nrow(data_db_failures_BV) == 0) {
  print("no failures....then no .csv file is going to be written...and sent") }





