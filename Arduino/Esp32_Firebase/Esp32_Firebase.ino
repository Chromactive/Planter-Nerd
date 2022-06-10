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
#define FIREBASE_HOST "https://arduino-e8bcf-default-rtdb.europe-west1.firebasedatabase.app/"
#define FIREBASE_AUTH "4fpVtnp9NePNpxr4msYt1CkEaljf7rAGLFlvhbAX"

// Sleep Time for 30 minutes
#define DEEP_SLEEP_TIME 1

// Firebase Data
FirebaseData firebaseData;
String node = "/Plants";

String plant2 = "/954ea1ba-0b01-4a07-bb1a-42ebc515b611";

// Firebase Paths
String tempPath = "/temp";
String soilHumPath = "/soilHum";
String lightPath = "/light";
String alertPath = "/alert";
String regaPath = "/waterPlant";
String modelPath = "/vase";

// Vase Sensores Consts
#define LightPin2 1
#define TempPin2 2
#define SoilHum2 3
#define alertPin2 4
#define rPin2 13
#define gPin2 12
#define bPin2 11

void setup() 
{
  Serial.begin(115200);

  //light pins for vase
  pinMode(alertPin2, OUTPUT);
  pinMode(rPin2, OUTPUT);
  pinMode(gPin2, OUTPUT);
  pinMode(bPin2, OUTPUT);
  
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
}


void loop(){
  pixels.setPixelColor(0, pixels.Color(0, 0, 20));
  pixels.show();
  
  //wake Firebase after delay
  //wakeUpFirebase();
  
  
  //escreve valores da planta e verifica se precisa de regar
  checkForRega(plant2, rPin2, gPin2, bPin2);
  writeValuesToDB(plant2, "vase");


  //waits for 5 seconds
  delay(5000);
  
  pixels.setPixelColor(0, pixels.Color(0, 0, 0));
  pixels.show();
 
  delay(60000 * DEEP_SLEEP_TIME);
}

void writeValuesToDB(String vaseID, String vaseModel){
  
  Serial.println();
  
  
      
    //read values from sensors
    Serial.println("Reading sensors for model 2");
    
    float lightValue = (float)getBestValue(LightPin2)/8191.0*100.0;
    Firebase.pushFloat(firebaseData, node + vaseID + lightPath, lightValue);
    Serial.print("Light2 = "); Serial.println(lightValue);
    Serial.println(node + vaseID + lightPath);
    float soilHumValue = (float)getBestValue(SoilHum2)/8191.0*100.0;
    Firebase.pushFloat(firebaseData, node + vaseID + soilHumPath, soilHumValue);
    turnOnRGBLedForHumidity(rPin2, gPin2, bPin2, soilHumValue);
    Serial.print("Soil2 = "); Serial.println(soilHumValue);
    
    //float tempValue = getTemperature(getBestValue(TempPin2));
    float tempValue = random(2000, 2500)/100.00;
    Firebase.pushFloat(firebaseData, node + vaseID + tempPath, tempValue);
    Serial.print("Temp2 = "); Serial.println(tempValue);
    
    if(!checkParameters(vaseID, soilHumValue, tempValue))
      sendAlert(vaseID, alertPin2);
      
  
    
}

void turnOnRGBLedForHumidity(int rPin, int gPin, int bPin, float humVal){
  if(humVal >= 75.0){
    digitalWrite(rPin, LOW);
    digitalWrite(gPin, LOW);
    digitalWrite(bPin, HIGH);
  }
  else if(humVal >= 50.0 && humVal < 75.0){
    digitalWrite(rPin, LOW);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, LOW);
  }
  else if(humVal >= 25.0 && humVal < 50.0){
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, LOW);
  }
  else{
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, LOW);
    digitalWrite(bPin, LOW);
  }
}

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
  float R1 = 10000;
  float logR2, R2, T, Tc, Tf; 
  float c1 = 1.009249522e-03, c2 = 2.378405444e-04, c3 = 2.019202697e-07;
  
  R2 = R1 * (4095.0 / (float)val - 1.0);
  logR2 = log(R2);
  T = (1.0 / (c1 + c2*logR2 + c3*logR2*logR2*logR2));
  Tc = T - 273.15;

  return Tc;
}

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

void sendAlert(String vaseID, int redLedPin){
  Firebase.setBool(firebaseData, node + vaseID + alertPath, true);
  digitalWrite(redLedPin, HIGH);
}

void checkForRega(String vaseID, int rLED, int gLED, int bLED){
  
  if(Firebase.getBool(firebaseData, node + vaseID + regaPath)){
    //rega durante 10 segundos simulado com led RGB branco
    Firebase.setBool(firebaseData, node + vaseID + regaPath, false);
    digitalWrite(rLED, HIGH);
    digitalWrite(gLED, HIGH);
    digitalWrite(bLED, HIGH);
    delay(10000);
  }
  
}

void wakeUpFirebase(){
  Firebase.pushFloat(firebaseData, node + "/wake", 1);
  //waits for 5 seconds
  delay(7000);
}
