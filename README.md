# Thermometer-project
### Made by GustavPetterssonBjorklund as an assignment for Hitachigymnasiet vasteras

### OBS!
 - The webserver is made in an arch linux enviornment and it's highly recommended to use the same if you're setting this up on your local system
 - The setup guide is far from comprehensive, if you find something critical missing, please make an issue :D


## REQUIREMENTS (brief)
### SERVER
 - apache
 - mysql 
 - php
### Thermometer (required to post data)
#### Thermometer:
 - github : https://github.com/hgguspet/Thermometer-project-sensor
#### Thermometer requirements:
 - Arduino-HMAC-SHA256, required my Thermometer : https://github.com/GustavPetterssonBjorklund/Arduino-HMAC-SHA256.git
 - ArduinoBearSSL, required by Arduino-HMAC-SHA256 : https://github.com/arduino-libraries/ArduinoBearSSL.git
#### A setup guide for the Thermometer can be found on it's github page



### Setup mysql (required)
#### !Make sure! to use the same names for the table columns or you will need to edit the source code
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

### Additional setup required in the local enviornment
#### (Required)
 - setup apache

## Example setup
<details>
  <summary>Httpd conf</summary>
```conf
# Define the ServerRoot directory
ServerRoot "/etc/httpd"

# Listen on port 80
Listen 80

# Load essential Apache modules
# LoadModule mpm_event_module /usr/lib/httpd/modules/mod_mpm_event.so (breaks php)
LoadModule mpm_prefork_module /usr/lib/httpd/modules/mod_mpm_prefork.so
LoadModule authn_file_module /usr/lib/httpd/modules/mod_authn_file.so
LoadModule authn_core_module /usr/lib/httpd/modules/mod_authn_core.so
LoadModule authz_host_module /usr/lib/httpd/modules/mod_authz_host.so
LoadModule authz_groupfile_module /usr/lib/httpd/modules/mod_authz_groupfile.so
LoadModule authz_user_module /usr/lib/httpd/modules/mod_authz_user.so
LoadModule authz_core_module /usr/lib/httpd/modules/mod_authz_core.so
LoadModule access_compat_module /usr/lib/httpd/modules/mod_access_compat.so
LoadModule auth_basic_module /usr/lib/httpd/modules/mod_auth_basic.so
LoadModule reqtimeout_module /usr/lib/httpd/modules/mod_reqtimeout.so
LoadModule include_module /usr/lib/httpd/modules/mod_include.so
LoadModule filter_module /usr/lib/httpd/modules/mod_filter.so
LoadModule mime_module /usr/lib/httpd/modules/mod_mime.so
LoadModule log_config_module /usr/lib/httpd/modules/mod_log_config.so
LoadModule env_module /usr/lib/httpd/modules/mod_env.so
LoadModule headers_module /usr/lib/httpd/modules/mod_headers.so
LoadModule setenvif_module /usr/lib/httpd/modules/mod_setenvif.so
LoadModule version_module /usr/lib/httpd/modules/mod_version.so
LoadModule unixd_module /usr/lib/httpd/modules/mod_unixd.so
LoadModule status_module /usr/lib/httpd/modules/mod_status.so
LoadModule autoindex_module /usr/lib/httpd/modules/mod_autoindex.so
LoadModule negotiation_module /usr/lib/httpd/modules/mod_negotiation.so
LoadModule dir_module /usr/lib/httpd/modules/mod_dir.so
LoadModule userdir_module /usr/lib/httpd/modules/mod_userdir.so
LoadModule alias_module /usr/lib/httpd/modules/mod_alias.so
LoadModule rewrite_module /usr/lib/httpd/modules/mod_rewrite.so
LoadModule php_module modules/libphp.so

AddHandler php-script .php





# Define the User and Group Apache runs as
<IfModule unixd_module>
    User http
    Group http
</IfModule>

# ServerAdmin email for server-related issues
ServerAdmin you@example.com

# DocumentRoot: The directory out of which you will serve your documents
DocumentRoot "<your server host dir>"

# Directory permissions for DocumentRoot
<Directory "<your server host dir>">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

# DirectoryIndex: the file Apache will serve if a directory is requested
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

# Deny access to all hidden files (like .htaccess and .htpasswd)
<Files ".ht*">
    Require all denied
</Files>

# Error and access log files
ErrorLog "/var/log/httpd/error_log"
CustomLog "/var/log/httpd/access_log" common

# Log format
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    CustomLog "/var/log/httpd/access_log" combined
</IfModule>

# ScriptAlias for CGI-bin (if needed)
ScriptAlias /cgi-bin/ "/srv/http/cgi-bin/"
<Directory "/srv/http/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

# Load additional configuration files
Include conf/extra/httpd-mpm.conf
Include conf/extra/httpd-multilang-errordoc.conf
Include conf/extra/httpd-autoindex.conf
Include conf/extra/httpd-languages.conf
Include conf/extra/httpd-userdir.conf
Include conf/extra/httpd-default.conf
Include conf/extra/php_module.conf
```
</details>

#### (Recommended)
 - setup a Cron Job with crontab -e and add the line 
```crontab
30 * * * * php /home/<username>/Thermometer-project/scripts/update_hourly_avg.php
```

 ### Credits:
 - GustavPetterssonBjorklund - coding
