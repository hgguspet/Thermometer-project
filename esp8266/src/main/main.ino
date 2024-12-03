//REQUIREMENTS
//- Arduino-HMAC-SHA256 library 
//  - ArduinoBearSSL


#include <Arduino-HMAC-SHA256.h>

// get sensitive data from file included in the .gitignore
#include "sensitive_data.h"


#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>  // For HTTP requests

// dht sensor 
#include "DHT.h"
#define DHTPIN 12
#define DHTTYPE DHT11 

// intialize sensor
DHT dht(DHTPIN, DHTTYPE);

// get sensitive data from sensitive_data.h
const char* ssid = sensitive_data::ssid;
const char* wifipwd = sensitive_data::wifipwd;
const char* serverUrl = sensitive_data::serverUrl;
const char* secretKey = sensitive_data::secretKey;




// Temperature and humidity values as floats
float temp;
float hum;

// create instances of objects
HTTPClient http;
WiFiClient client;
HMAC_SHA256 hmac;

///@brief function to print wifi response from wifi response buffer
void printWiFiResponse(int& httpCode) {
  // if there exists a buffered response code
  if (httpCode > 0) {
    // get and print the response
    String payload = http.getString();
    Serial.print("Response: ");
    Serial.println(payload);
  } else {
    // if no http response, print error
    Serial.print("Error on HTTP request: ");
    Serial.println(httpCode);
  }

}

///@brief get the HashHex using the Arduino-HMAC-SHA256 library
String getHashHex(const float& temp, const float& hum, const char* secretKey) {
  
  // combine and format temp, hum as UTF-8 string with 2 decimal precision
  float sum = temp + hum;
  String message = String(sum, 2);  // Should be "100.00" in this example

  // Generate the HMAC hash
  String hashHex = hmac.GET_HMAC_SHA_256_HASH(message, secretKey);

  // Print debugging details
  Serial.print("Generated Hash (HMAC): ");
  Serial.println(hashHex);
  Serial.print("Message: ");
  Serial.println(message);

  // return the hash
  return hashHex;
}

///@brief perform a get request to the remote db with temp, hum, hash
///@param serverUrl url to the push_data.php file
///@param temp float temperature form DHT11 sensor
///@param hum float humidity from DHT11 sensor
///@param hashHex string from HMAC hash lib in hex for, used for authenication
int performGetRequest(const String serverUrl, const float& temp, const float& hum, const String& hashHex) {
  // Construct the full URL with query parameters
  String url = String(serverUrl) + "?temp=" + String(temp, 2) + "&hum=" + String(hum, 2) + "&key=" + hashHex;
  Serial.print("Requesting URL: ");
  Serial.println(url);
  
  // initialize wifi client with the url
  http.begin(client, url); 
  // send get request
  int httpCode = http.GET(); 

  // return the response status code 
  return httpCode;
}
///@brief function to set the temp and hum to values read from the sensor
///@note the DHT11 sensor is very slow and may require more than 250ms to read values
void setTempHum(float& t, float& h) {
  h = dht.readHumidity();
  t = dht.readTemperature();

  // if hum or temp can't be interpreted as number return early
  if (isnan(h) || isnan(t)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }
}


///@brief start: serial, dht, wifi ; additionally: connect to wifi
void setup() {

  Serial.begin(115200);
  dht.begin();

  // Start WiFi connection
  WiFi.begin(ssid, wifipwd);


  // attempt wifi connection
  Serial.println("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  // proceed when the wifi in connected
  Serial.println();
  Serial.println("Connected to WiFi");
}


///@brief keep updating the remote db every 5000 ms
void loop() {
  setTempHum(temp, hum);
  String hashHex = getHashHex(temp, hum, secretKey);
  int httpCode = performGetRequest(serverUrl, temp, hum, hashHex);
  printWiFiResponse(httpCode);
  Serial.println("WiFi Signal Strength: " + String(WiFi.RSSI()) + " dBm");

  delay(5000);
}