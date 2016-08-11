# Cron examples
# crontab -e
# Will open vim
# */5 * * * * Rscript /home/federicok/cron_testing/code_prova_sync.R

# Set a working directory as in gisdev server
setwd("/home/federicok/cron_testing")


# Get system time
tm <- Sys.time()
tm <- as.character(tm)

# Remove odd characters
file_name <- gsub(":| |-", "_", tm)

# Write file
write(tm, paste0(file_name, ".txt"))
# write.table(tm,file="C:/z_scores_volatiles/OUT.TXT", sep='\t')
