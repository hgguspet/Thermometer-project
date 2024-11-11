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

### Setup mysql (required)
1. Make a new mysql database, default name is thermometer_data
```sql
CREATE DATABASE thermometer_data;
```
2. (Recommended) Make a new user
```sql
CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'user_password';
```
3. If you made a new user, give the user permissions over the database
```sql
GRANT ALL PRIVILEGES ON thermometer_data.* TO 'new_user'@'localhost';
```
 - Remember to flush the privileges
```sql
FLUSH PRIVILEGES;
```
4. Make a new table for the buffer readings, ex:
```sql
CREATE TABLE bufferTable (
    temp FLOAT NOT NULL,
    hum FLOAT NOT NULL,
    date TIMESTAMP DEFAULT current_timestamp()
);
```
5. Make a new table for the hourly averages, ex:
```sql
CREATE TABLE `hourly_avg` (
  `avg_temp` float DEFAULT NULL,
  `avg_hum` float NOT NULL,
  `reading_time` datetime DEFAULT current_timestamp(),
  `reading_date` date GENERATED ALWAYS AS (cast(`reading_time` as date)) VIRTUAL,
  `reading_hour` int(11) GENERATED ALWAYS AS (hour(`reading_time`)) VIRTUAL,
  UNIQUE KEY `reading_date` (`reading_date`,`reading_hour`)
);
```

### Setup a sensitive_data.php file (required)

1. Open / create the sensitive_data.php file
```terminal
sudo nano scripts/sensitive_data.php
```

2. Paste the following template setup
```php
<?php

$servername = "localhost";
$username = "<your mysql_username>";

// change if you made a database with a different name
$database = "thermometer_data";

// change if you chose other table names as opposed to the examples above
$bufferTable = "bufferTable";
$hourlyTable = "hourly_avg";


// Start of sensitive info
$mysqlpwd = "<your mysql_passphrase>";

// make sure to set the same salt for the esp8266
$postpwd = "<salt for HMAC hasing>";
// End of sensitive info

?>
```

### OBS!
 - The webserver is made in an arch linux env and it's highly recommended to use the same if you're setting this up on your local system
 - The setup guide is far from comprehensive, if you find something critical missing, please make an issue :D


 ### Credits:
 - GustavPetterssonBjorklund - coding
