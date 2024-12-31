#include <Arduino.h>
#include <Wire.h>
#include <DHT.h>
#include <DHT_U.h>
#include <Adafruit_SGP30.h>

/*
    Pins definitions. SDA and SCL omitted.
*/
#define PIN_DHT 7
#define PIN_CO A0
#define PIN_NH3 A1
#define PIN_NO2 A2
#define PIN_DUST_LED 2
#define PIN_DUST_AOUT A3

#define COV_RATIO 0.2       // ug/mmm / mv
#define NO_DUST_VOLTAGE 400 // mV
#define SYS_VOLTAGE 3300    // mV

// Serial print helper function for printing to serial
#define spl(data) Serial.println(F(data))
#define sp(data) Serial.print(F(data))
#define s(data) Serial.print(data)
#define sl(data) Serial.println(data)
#define sb sp(";")

DHT_Unified dht(PIN_DHT, DHT22);
Adafruit_SGP30 sgp;

// Taken from Waveshare's example code for Dust Sensor - https://www.waveshare.com/wiki/Dust_Sensor
int Filter(int m)
{
  static int flag_first = 0, _buff[10], sum;
  const int _buff_max = 10;
  int i;

  if (flag_first == 0)
  {
    flag_first = 1;
    for (i = 0, sum = 0; i < _buff_max; i++)
    {
      _buff[i] = m;
      sum += _buff[i];
    }
    return m;
  }
  else
  {
    sum -= _buff[0];
    for (i = 0; i < (_buff_max - 1); i++)
    {
      _buff[i] = _buff[i + 1];
    }
    _buff[9] = m;
    sum += _buff[9];

    i = sum / 10.0;
    return i;
  }
}

// Converts degrees C to F
int C_to_F(float tempC)
{
  return round(tempC * 9 / 5 + 32);
}

// from Adafruit_SGP30 example
uint32_t getAbsoluteHumidity(float temperature, float humidity)
{
  // approximation formula from Sensirion SGP30 Driver Integration chapter 3.15
  const float absoluteHumidity = 216.7f * ((humidity / 100.0f) * 6.112f * exp((17.62f * temperature) / (243.12f + temperature)) / (273.15f + temperature)); // [g/m^3]
  const uint32_t absoluteHumidityScaled = static_cast<uint32_t>(1000.0f * absoluteHumidity);                                                                // [mg/m^3]
  return absoluteHumidityScaled;
}

void setup()
{
  Serial.begin(115200);
  spl("Setup begins...");

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  Wire.begin();
  sgp.begin();
  dht.begin();

  pinMode(PIN_CO, INPUT);
  pinMode(PIN_NH3, INPUT);
  pinMode(PIN_NO2, INPUT);

  pinMode(PIN_DUST_LED, OUTPUT);
  digitalWrite(PIN_DUST_LED, LOW);
  pinMode(PIN_DUST_AOUT, INPUT);

  spl("Setup ended!");
}

void loop()
{
  static unsigned long lastLog = 0;
  if (millis() - lastLog > 1000)
  {
    /*

      DHT22 - Temp and Humidity

    */
    int tempC, tempF, humidity;

    sensors_event_t event;
    dht.temperature().getEvent(&event);
    tempC = event.temperature;
    tempF = C_to_F(tempC);
    dht.humidity().getEvent(&event);
    humidity = event.relative_humidity;

    s(tempF);    // send data in degrees F
    sb;          // this just prints ';'
    s(humidity); // relative humidity in %
    sb;

    /*

      Dust sensor - most of the code here comes from Waveshare's example - https://www.waveshare.com/wiki/Dust_Sensor

    */
    digitalWrite(PIN_DUST_LED, HIGH);
    delayMicroseconds(280);
    int dustAnalogValue = analogRead(PIN_DUST_AOUT);
    digitalWrite(PIN_DUST_LED, LOW);

    dustAnalogValue = (3300.0 / 1024.0) * Filter(dustAnalogValue) * 11;
    if (dustAnalogValue >= NO_DUST_VOLTAGE)
    {
      dustAnalogValue -= NO_DUST_VOLTAGE;
      dustAnalogValue = dustAnalogValue * COV_RATIO;
    }
    else
      dustAnalogValue = 0;

    s(dustAnalogValue); // in ug/m3 (nano grams per cube meter)
    sb;

    /*

      SGP30 Gas Detector Sensor Module

    */
    sgp.setHumidity(getAbsoluteHumidity(tempC, humidity));
    sgp.IAQmeasure();
    s(sgp.TVOC); // in ppb / parts per billion
    sb;
    s(sgp.eCO2); // in ppm / parts per million
    sb;

    /*

      MICS-6814 CO, NH3, NO2 sensor.
      Raw values. Not in any units.
      Can be used only to detect increase/decrease.

    */
    s(analogRead(PIN_CO));
    sb;
    s(analogRead(PIN_NH3));
    sb;
    s(analogRead(PIN_NO2));
    sb;

    Serial.println();
    lastLog = millis();
  }
}
