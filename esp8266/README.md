# Thermometer-project-sensor
### This is part of the Thermometer-project made by GustavPetterssonBjorklund as an assignment for Hitachigymnasiet
#### Main repository : https://github.com/hgguspet/Thermometer-project.git

## REQUIREMENTS
- Arduino-HMAC-SHA: https://github.com/GustavPetterssonBjorklund/Arduino-HMAC-SHA256.git
- ArduinoBearSSL, required by Arduino-HMAC-SHA256 : https://github.com/arduino-libraries/ArduinoBearSSL.git

## REQUIRED SETUP
1. Make a new file called "sensitive_data.h" in src/main/
2. Paste the following template and input your values:
```cpp
#ifndef SENSITIVE_DATA_H
#define SENSITIVE_DATA_H

namespace sensitive_data {
  const char* ssid = "<your ssid>";
  const char* wifipwd = "<your wifi passphrase>";

  const char* serverUrl = "<url to your server + /scripts/push_data.php>";
  const char* secretKey = "<your post salt as specified in the servers scripts/sensitive_data.php>";
}

#endif // SENSITIVE_DATA_H
```

### If you encounter an issue or find something that could be improved, please create an issue

## Credits
- GustavPetterssonBjorklund - coding

