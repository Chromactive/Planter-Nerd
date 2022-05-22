
const int TEMPERATURE_SENSOR_PIN = A0; // Arduino pin connected to temperature sensor's  pin
const int TEMPERATURE_LED_PIN = 3;  // Arduino pin connected to LED's pin
const int TEMPERATURE_THRESHOLD = 560; // 

const int LIGHT_SENSOR_PIN = A2; // Arduino pin connected to light sensor's  pin
const int LIGHT_LED_PIN = 5;  // Arduino pin connected to LED's pin
const int LIGHT_THRESHOLD = 100;

// variables will change:
int temperatureValue;
int lightValue;

void setup() {
  Serial.begin(9600);
  pinMode(TEMPERATURE_LED_PIN, OUTPUT);
  pinMode(LIGHT_LED_PIN, OUTPUT); 
}

void loop() {
  
  temperatureValue = analogRead(TEMPERATURE_SENSOR_PIN); // read the input on analog pin
  
  if(temperatureValue < TEMPERATURE_THRESHOLD)
    digitalWrite(TEMPERATURE_LED_PIN, LOW); // turn off LED
  else
    digitalWrite(TEMPERATURE_LED_PIN, HIGH);  // turn on LED

  lightValue = analogRead(LIGHT_SENSOR_PIN);
  
  if(lightValue < LIGHT_THRESHOLD)
    digitalWrite(LIGHT_LED_PIN, HIGH); // turn on LED
  else
    digitalWrite(LIGHT_LED_PIN, LOW);  // turn off LED
}
