#### Thermometer-project

###REQUIREMENTS
##SERVER
#-apache
#-mysql (requires manual setup)
#-php

##Thermometer
#-Unknown

##REQUIRE SETUP IN LOCAL ENV
#The following will be a setup guide for arch as that is the os this project was made in

#setup a Cron Job with crontab -e and add the line "0 * * * * php home/<username>/Thermometer-project/scripts/update_hourly_avg.php"
