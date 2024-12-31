class SensorData {
  int temperature;  // F
  int humidity;     // relative humidity in %
  int co2;          // ppm
  int tvoc;         // in ppb
  int dust;         // ug/m3
  int co, nh3, no2; // relative change, not any meaningful units

  double latitude, longitude; // Added location fields

  // Default constructor
  SensorData() {
    temperature = 0;
    humidity = 0;
    co2 = 0;
    tvoc = 0;
    dust = 0;
    co = 0;
    nh3 = 0;
    no2 = 0;
    latitude = 0.0;
    longitude = 0.0;
  }

  // Full constructor
  SensorData(int temperature, int humidity, int co2, int tvoc, int dust, 
             int co, int nh3, int no2, double latitude, double longitude, long timestamp) {
    this.temperature = temperature;
    this.humidity = humidity;
    this.co2 = co2;
    this.tvoc = tvoc;
    this.dust = dust;
    this.co = co;
    this.nh3 = nh3;
    this.no2 = no2;
    this.latitude = latitude;
    this.longitude = longitude;
  }

  // Copy constructor
  SensorData(SensorData other) {
    this.temperature = other.temperature;
    this.humidity = other.humidity;
    this.co2 = other.co2;
    this.tvoc = other.tvoc;
    this.dust = other.dust;
    this.co = other.co;
    this.nh3 = other.nh3;
    this.no2 = other.no2;
    this.latitude = other.latitude;
    this.longitude = other.longitude;
  }

  // Display data (for debugging or visualization)
  void display() {
    println("Temperature: " + temperature + " °F");
    println("Humidity: " + humidity + " %");
    println("CO2: " + co2 + " ppm");
    println("TVOC: " + tvoc + " ppb");
    println("Dust: " + dust + " µg/m³");

    println("CO: " + co + " raw value");
    println("NH3: " + nh3 + " raw value");
    println("NO2: " + no2 + " raw value");

    println("Location: Latitude " + latitude + ", Longitude " + longitude);
  }
}

float tempFtoC(float tempF)
{
    return (tempF - 32) * 5 / 9;
}
float tempCtoF(float tempC)
{
    return tempC * 9 / 5 + 32;
}

// save values, so if reading failed on this frame/update, return last good known values
SensorData previousData = new SensorData();

SensorData readSerial()
{
  // start with previous known-good values
  SensorData toReturn = new SensorData(previousData);

  if (myPort != null && myPort.available() > 0)
  {
    String values[] = null;

    // try reading serial until end reached, use only last valid value
    while(myPort.available() > 0)
    {
      String input = myPort.readStringUntil('\n');
      input = trim(input);
      String[] tempValues = split(input, ';');

      //println("Read[" + tempValues.length + "]: " + input);

      if(tempValues != null && tempValues.length == 9)
      {
        values = tempValues;
      }
    }

    // if read valid data
    if (values != null && values.length == 9)
    {
      int counter = 0;

      toReturn.temperature = int(values[counter++]);
      toReturn.humidity = int(values[counter++]);

      toReturn.dust  = int(values[counter++]);

      toReturn.tvoc =  int(values[counter++]);
      toReturn.co2 = int(values[counter++]);
      
      toReturn.co = int(values[counter++]);
      toReturn.nh3 = int(values[counter++]);
      toReturn.no2 = int(values[counter++]);

      //this comes from DataScreen.pde global var location[]
      if (location != null)
      {
        toReturn.latitude = location[0];
        toReturn.longitude = location[1];
      }

      previousData = toReturn;
    }
    else
    {
      return previousData;
    }
  }

  // if in debug / simulation mode
  else if (myPort == null)
  {
    toReturn.temperature = randomInt(60, 90);
    toReturn.humidity = randomInt(30, 99);

    toReturn.dust = randomInt(20, 200);

    toReturn.co2 = randomInt(400, 2000);
    toReturn.tvoc = randomInt(0, 3000);

    toReturn.co = randomInt(0, 1023);
    toReturn.nh3 = randomInt(0, 1023);
    toReturn.no2 = randomInt(0, 1023);
    
    if (location != null)
      {
        toReturn.latitude = location[0];
        toReturn.longitude = location[1];
      }

  }

  //sensorData.display(); // Print new data to console for debugging
  return toReturn;
}

int randomInt(int start, int end)
{
  return int(random(start, end));
}
