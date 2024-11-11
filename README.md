# Thermometer-project

### REQUIREMENTS
#### SERVER
 - apache
 - mysql 
 - php

### Thermometer 
 - github : https://github.com/hgguspet/Thermometer-project-sensor

### Required setup in local enviornment
#### The following will be a setup guide for arch as that is the os this project was made in

 - setup a Cron Job with crontab -e and add the line "0 * * * * php home/<username>/Thermometer-project/scripts/update_hourly_avg.php"
 - setup apache

### Setup mysql
1. Make a new mysql database, default name is thermometer_data 
```sql
CREATE TABLE readings (
    temp FLOAT NOT NULL,
    hum FLOAT NOT NULL,
    date_of_creation TIMESTAMP DEFAULT current_timestamp()
);
```



### OBS!
 - The webserver is made in an arch linux env and it's highly recommended to use the same if you're setting this up on your local system
 - The setup guide is far from comprehensive, if you find something critical missing, please make an issue :D


 ### Credits:
 - GustavPetterssonBjorklund - coding
