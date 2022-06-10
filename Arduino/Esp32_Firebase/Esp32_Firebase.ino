/* 
*   Vase
*   temperature sensor
*   light sensor
*   soild humidity sensor
*   red LED
*   RGB LED
*/

#include <WiFi.h>
#include "FirebaseESP32.h"
#include <Adafruit_NeoPixel.h>
#define PIN 18
#define NUMPIXELS 1

Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

// Wifi config
#define WIFI_SSID "baloni"
#define WIFI_PASSWORD "L528k925"

// Firebase config
#define FIREBASE_HOST "https://pepperoni-nipples-default-rtdb.europe-west1.firebasedatabase.app/"
#define FIREBASE_AUTH "wjjhEdV3CtHqhzPjHsrRVR8STLC0xBd0v7frHHxE"

// Sleep Time for 30 minutes
#define DEEP_SLEEP_TIME 1

// Firebase Data
FirebaseData firebaseData;
String node = "/Plants";

String plant = "/954ea1ba-0b01-4a07-bb1a-42ebc515b611";

// Firebase Paths
String tempPath = "/temp";
String soilHumPath = "/soilHum";
String lightPath = "/light";
String alertPath= "/alert";
String okPath = "/okay";
String regaPath = "/waterPlant";
String modelPath = "/vase";

// Vase Sensores Consts
#define LightPin 1
#define TempPin 2
#define SoilHum 3
#define alertPin 4
#define rPin1 13
#define gPin1 12
#define bPin1 11

void setup() 
{
  Serial.begin(115200);

  //light pins for vase
  pinMode(alertPin, OUTPUT);
  pinMode(rPin1, OUTPUT);
  pinMode(gPin1, OUTPUT);
  pinMode(bPin1, OUTPUT);
  
  pixels.begin();
  Serial.println();
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
 
  Serial.println();
  Serial.println(WiFi.localIP());
  Serial.println("Connected");

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Serial.println("FireBase connected");
  Firebase.reconnectWiFi(true);

  Firebase.setFloat(firebaseData, node + plant + "/minSoilHum", 23.0);
  Firebase.setFloat(firebaseData, node + plant + "/maxSoilHum", 200.0);
  Firebase.setFloat(firebaseData, node + plant + "/minTemp", 10.0);
  Firebase.setFloat(firebaseData, node + plant + "/maxTemp", 50.0);
}


void loop(){
  pixels.setPixelColor(0, pixels.Color(0, 0, 20));
  pixels.show();
  
  //escreve valores da planta e verifica se precisa de regar
  checkForRega(plant);
  writeValuesToDB(plant, "vase");


  //waits for 5 seconds
  delay(5000);
  
  pixels.setPixelColor(0, pixels.Color(0, 0, 0));
  pixels.show();
 
  delay(60000 * DEEP_SLEEP_TIME);
}

void writeValuesToDB(String vaseID, String vaseModel){
  
    Serial.println();
  
    //read values from sensors
    Serial.println("Reading sensors for model");
    
    float lightValue = (float)getBestValue(LightPin)/8191.0*100.0;
    Firebase.setFloat(firebaseData, node + vaseID + lightPath, lightValue);
    Serial.print("Light = "); Serial.println(lightValue);
    
    float soilHumValue = (float)getBestValue(SoilHum)/8191.0*100.0;
    Firebase.setFloat(firebaseData, node + vaseID + soilHumPath, soilHumValue);
    turnOnRGBLedForHumidity(rPin1, gPin1, bPin1, soilHumValue);
    Serial.print("Soil = "); Serial.println(soilHumValue);
    
    //float tempValue = getTemperature(getBestValue(TempPin));
    float tempValue = random(2000, 2500)/100.00;
    Firebase.setFloat(firebaseData, node + vaseID + tempPath, tempValue);
    Serial.print("Temp = "); Serial.println(tempValue);
    
    if(!checkParameters(vaseID, soilHumValue, tempValue)){
      sendAlert(vaseID);
      
    }
    else {
      itIsOkay(vaseID, alertPin);
      
    } 
  
    
}

void turnOnRGBLedForHumidity(int rPin, int gPin, int bPin, float humVal){
  //valores de humidade altos, fica azul
  if(humVal >= 75.0){
    digitalWrite(rPin, LOW);
    digitalWrite(gPin, LOW);
    digitalWrite(bPin, HIGH);
  }
  //valores de humidade normais, fica verde
  else if(humVal >= 50.0 && humVal < 75.0){
    digitalWrite(rPin, LOW);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, LOW);
    Serial.println("Verde");
  }
 
  //valores de humidade muito baixo, fica vermelho
  else{
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, LOW);
    digitalWrite(bPin, LOW);
    Firebase.setBool(firebaseData, node + plant + regaPath, true);
  }
}

//devolve a média de 8 valores, retirando o maior e o menor valor para nao ser bias
float getBestValue(int pin){
  float values[10];

  for(int i = 0; i<10; i++){
    values[i] = analogRead(pin);
    delay(1000);
  }

  // remover maior e menor valor
  float maxVal = -100000.0, minVal = 100000.0;

  float sumVals = 0.0;
  int maxIndex, minIndex;
  for(int i = 0; i<10; i++){
    if(values[i] > maxVal){
      maxVal = values[i];
      maxIndex = i;
    }
    if(values[i] < minVal){
      minVal = values[i];
      minIndex = i;
    }
  }
  values[maxIndex] = values[minIndex] = -404;
  
  // soma os 8 valores restantes
  for(int i = 0; i<10; i++){
    if(values[i] != -404){
      sumVals += values[i];
    }
  }

  // devolve a media dos 8 valores
  return sumVals/8.0;
}

float getTemperature(float val){
  
  float voltage = (val) * (5.0);
  voltage /= 1024;
  
  float temperatureC = (voltage - 0.5) * 100 ;
  
  return temperatureC;
}

//todo define min and max values for temp and humidity
boolean checkParameters(String vaseID, float soilHumValue, float tempValue){

  Firebase.getFloat(firebaseData, node + vaseID + "/minSoilHum");
  float minSoilHumVal = firebaseData.floatData();
  Firebase.getFloat(firebaseData, node + vaseID + "/maxSoilHum");
  float maxSoilHumVal = firebaseData.floatData();
  
  Firebase.getFloat(firebaseData, node + vaseID + "/minTemp");
  float minTempVal = firebaseData.floatData();
  Firebase.getFloat(firebaseData, node + vaseID + "/maxTemp");
  float maxTempVal = firebaseData.floatData();

  if(soilHumValue < minSoilHumVal || soilHumValue > maxSoilHumVal || tempValue < minTempVal || tempValue > maxTempVal){
    return false;  
  }
  return true;
}

void sendAlert(String vaseID){
  Firebase.setBool(firebaseData, node + vaseID + alertPath, true);
  digitalWrite(alertPin, HIGH);
}
void itIsOkay(String vaseID, int redLedPin){
  Firebase.setBool(firebaseData, node + vaseID + okPath, true);
  digitalWrite(redLedPin, LOW);
}


void checkForRega(String vaseID){
  Firebase.getBool(firebaseData, node + vaseID + regaPath);
  bool rega = firebaseData.boolData();
  if(rega){
    //rega durante 10 segundos simulado com led RGB branco
    Firebase.setBool(firebaseData, node + vaseID + regaPath, false);
    digitalWrite(rPin1, LOW);
    digitalWrite(gPin1, HIGH);
    digitalWrite(bPin1, LOW);
   
    delay(10000);
  }
  
}
