#include <LiquidCrystal.h>

const int TEMPERATURE_SENSOR_PIN = A0; // Arduino pin connected to temperature sensor's  pin
const int TEMPERATURE_LED_PIN = 9;  // Arduino pin connected to LED's pin
const int TEMPERATURE_THRESHOLD = 260; // 

const int LIGHT_SENSOR_PIN = A2; // Arduino pin connected to light sensor's  pin
const int LIGHT_LED_PIN = 8;  // Arduino pin connected to LED's pin
const int LIGHT_THRESHOLD = 250;

const int MOISTURE_SENSOR_PIN = A4; // Arduino pin connected to light sensor's  pin
const int MOISTURE_LED_PIN = 10;  // Arduino pin connected to LED's pin
const int MOISTURE_THRESHOLD = 300;

// variables will change:
int temperatureValue;
int lightValue;
int moistureValue;

LiquidCrystal lcd (7,6,5,4,3,2);
void setup() {
  Serial.begin(9600);
  pinMode(TEMPERATURE_LED_PIN, OUTPUT);
  pinMode(LIGHT_LED_PIN, OUTPUT);
  pinMode(MOISTURE_LED_PIN, OUTPUT);
  
  lcd.begin(8, 1);

//  lcd.autoscroll();
  
}

void loop() {
  
  temperatureValue = analogRead(TEMPERATURE_SENSOR_PIN); // read the input on analog pin
  
  if(temperatureValue < TEMPERATURE_THRESHOLD)
    digitalWrite(TEMPERATURE_LED_PIN, LOW); // turn off LED
  else
    digitalWrite(TEMPERATURE_LED_PIN, HIGH);  // turn on LED

  
  
  lightValue = analogRead(LIGHT_SENSOR_PIN);   
  
  if(lightValue > LIGHT_THRESHOLD)
    digitalWrite(LIGHT_LED_PIN, HIGH); // turn on LED
  else
    digitalWrite(LIGHT_LED_PIN, LOW);  // turn off LED
  
  
  moistureValue = analogRead(MOISTURE_SENSOR_PIN);   
  
  if(moistureValue < MOISTURE_THRESHOLD)
    digitalWrite(MOISTURE_LED_PIN, HIGH); // turn on LED
  else
    digitalWrite(MOISTURE_LED_PIN, LOW);
  
 lgtv();
  
}

void lgtv(){
  //Temperatura 
  float temperatureC = sensorRawToC(temperatureValue);
  lcd.print("Hotness: ");
  lcd.print(temperatureC);
  lcd.print(" C");
 
  delay(3000);
  lcd.clear();
  
  //Humidade
  int moisture = map(moistureValue,1,890,0,100);
  lcd.print(" Humidity: ");
  lcd.print(moisture);
  lcd.print(" % ");
  
  delay(3000);
  lcd.clear();
  
  //Luz
  int lux = sensorRawToPhys(lightValue);
  lcd.print("Light: ");
  lcd.print(lux);
  lcd.print(" LUX");
  
  delay(3000);
  lcd.clear();
  
}
float sensorRawToC(int raw){

  float voltage = (temperatureValue) * (5.0);
  voltage /= 1024;
  
  float temperatureC = (voltage - 0.5) * 100 ;
  
  return temperatureC;
}

int sensorRawToPhys(int raw){
  // Conversion rule
  float Vout = float(raw) * (5 / float(1023));// Conversion analog to voltage
  float RLDR = (10000 * (5 - Vout))/Vout; // Conversion voltage to resistance
  int phys=500/(RLDR/1000); // Conversion resitance to lumen
  return phys;
}
