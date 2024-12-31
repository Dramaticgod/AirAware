
//http.request SEARCH UP THIS LIBRARY AND DOWNLOAD IT USING THE MANAGER
import http.requests.*;
PImage boxBackgroundImage;
int stateManager = 0; // Manages current screen
Screen currentScreen; // Active screen
User user;            // Stores user information
SensorData sensorData; // Global SensorData instance
int lastUpdateTime = 0; // Tracks the last update time for SensorData
SerialPortPicker portPicker;
Serial myPort;
int baudRate = 9600;


void setup() {
  size(1000, 1000); // Match InputScreen size

  // Initialize state manager and global SensorData
  user = new User();
  currentScreen = new InputScreen();
  sensorData = new SensorData(); // Initial empty SensorData
  setup_sound();
  
  portPicker = new SerialPortPicker(10, 10);  
  stateManager = -1; // to launch with port picker first
  boxBackgroundImage = loadImage("background.jpg");
}

void draw() {
  background(35); // Clear screen

  if (stateManager == -1)
  {
    portPicker.draw();
    return;
  }

  // Update SensorData every minute
  if (millis() - lastUpdateTime > 1000) 
  { 
    sensorData = readSerial(); // Generate new random SensorData
    // DONT UNCOMMENT THIS FOR A LONG WHILE, THIS USES GOOGLE'S API WHICH IS PAID IF IT GOES ABOVE CERTAIN NUMBER OF API CALLS. 
    //appendSensorData(sensorData);
    lastUpdateTime = millis(); // Reset update time
  }

  currentScreen.display(); // Display the current screen
}

void mousePressed() {
  if (stateManager == -1) 
  {
    int selectedPort = portPicker.mouseEvent();

    if(selectedPort == -2)
    {
      println("Selected working in demo mode");
      myPort = null;
      stateManager = 0;
    }
    else if (selectedPort >= 0)
    {
      print("Selected port '");
      print(portPicker.serialPorts[selectedPort]);
      println("'");

      myPort = new Serial(this, portPicker.serialPorts[selectedPort], baudRate);
      stateManager = 0;
    }

    return;
  }

  currentScreen.handleMouse();
}

void keyPressed() {
  if (stateManager == -1) return;
  currentScreen.handleKeyboard();
}
