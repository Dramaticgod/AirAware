float[] location = null;
boolean showPopup = false;
String popupMessage = "";
int popupDuration = 2000; // Popup duration in milliseconds
int popupStartTime = 0;

class DataScreen extends Screen {
  Button htmlPlaceholder, publishData;
  SensorAlert sensorAlert;
  float glowIntensity = 0; // For animated glow effect
  boolean glowIncreasing = true;

// Constructor
DataScreen() {
publishData = new Button(width / 2 - 149, height / 2 + 150, 300, 55, "Publish Data", color(255, 204, 0), color(50)); // Positioned above
htmlPlaceholder = new Button(width / 2 - 149, height / 2 + 220, 300, 55, "Open Maps", color(255, 204, 0), color(50)); // Positioned below



  sensorAlert = new SensorAlert();
}

void display() {
  background(35);

  // Draw centered "phone-like" rectangle
 drawShadowBoxImage(width / 2 - 160, height / 2 - 300, 320, 600, 20, color(255), color(200, 200, 200, 100), boxBackgroundImage);


  // Pretty Username
  drawPrettyTitle(user.name, width / 2, height / 2 - 240); // Moved title down


  // Thresholds for each sensor
  int tempThreshold = 95; // >95F seems reasonable?
  int humidityThreshold = 95; // also, getting to this humidity after rain is normal

  /*
    Here are some other CO2 levels and what they may indicate:

    400 ppm: The average level of CO2 in outdoor air
    400–1,000 ppm: A typical level in occupied spaces with good air exchange
    1,000–2,000 ppm: A level that may cause complaints of drowsiness and poor air
    2,000–5,000 ppm: A level that may cause headaches, sleepiness, and stagnant, stale, stuffy air
    5,000 ppm: A level that indicates unusual air conditions where high levels of other gases could also be present
    40,000 ppm: A level that is immediately harmful due to oxygen deprivation
  */
  int co2Threshold = 1000;

  /*
    Uncle Google says:
        "Many VOC level charts list the TVOC level of 2,200 ppb to 5,500 ppb as unacceptable. 
        A level of 660 ppb to 2,200 ppb is poor, while the target value is zero ppb to 65 ppb. 
        These are not official guidelines, but they can give you a basic idea of acceptable VOC levels."
  */
  int tvocThreshold = 2500;

  /*
    If I put sensor right on HEPA filter output, it will read ~50.
    If I hit my bed to make some dust float around (visible under strong flashlight), it will read ~120.
  */
  int dustThreshold = 200;

  /*
    This sensor is kinda broken, as it can measure % increase from "base" or from when sensor was powered up and was done heating.
    (assuming I'm reading the datasheet correctly)

    That means we can't measure any units unless we "calibrated" the sensor in known environment.
    
    In my room, it reads around 250-350. Reading from Arduino is just raw value obtained from analogRead(), so it can range 0-1023.
    
    Google says:
        Here are some  CO levels and their associated health effects:

        1–70 ppm
          Most people won't experience symptoms, but some heart patients may have increased chest pain 

        > 70 ppm
          Symptoms of CO poisoning may become noticeable, such as headache, fatigue, and nausea 
        > 400 ppm
          Can be fatal, so you should evacuate immediately and call 911 from outside 
        50 ppm
          The Occupational Safety & Health Administration (OSHA) PEL for CO, which is the maximum allowable concentration for continuous exposure for healthy adults in any eight-hour period 

    "Average levels in homes without gas stoves vary from 0.5 to 5 parts per million (ppm)"
  */
  int coThreshold = 4; // This is just assumption.
  int calculatedCOvalue = sensorData.co / 250; // This is just assumption.
  

sensorAlert.checkThreshold("Temperature", sensorData.temperature, tempThreshold, width / 2 - 150, height / 2 - 170, 130, 70, 10, color(240, 128, 128), color(255, 69, 69), "F"); // Soft Red with Bold Border
sensorAlert.checkThreshold("Humidity", sensorData.humidity, humidityThreshold, width / 2 + 20, height / 2 - 170, 130, 70, 10, color(173, 216, 230), color(70, 130, 180), "%"); // Light Blue with Steel Border
sensorAlert.checkThreshold("CO2", sensorData.co2, co2Threshold, width / 2 - 150, height / 2 - 70, 130, 70, 10, color(152, 251, 152), color(34, 139, 34), "ppm"); // Mint Green with Forest Border
sensorAlert.checkThreshold("TVOC", sensorData.tvoc, tvocThreshold, width / 2 + 20, height / 2 - 70, 130, 70, 10, color(255, 218, 185), color(255, 140, 0), "ppb"); // Peach with Deep Orange Border
sensorAlert.checkThreshold("Dust", sensorData.dust, dustThreshold, width / 2 - 150, height / 2 + 30, 130, 70, 10, color(240, 230, 140), color(189, 183, 107), "μg/m3"); // Khaki with Dark Khaki Border
sensorAlert.checkThreshold("CO", calculatedCOvalue, coThreshold, width / 2 + 20, height / 2 + 30, 130, 70, 10, color(216, 191, 216), color(148, 0, 211), "ppm"); // Lavender with Dark Violet Border




  // HTML Placeholder Box
  htmlPlaceholder.display();
  publishData.display();
  showPopupMessage();
  // Update glow intensity for animation
  if (glowIncreasing) {
      glowIntensity += 0.5;
      if (glowIntensity > 100) glowIncreasing = false;
    } else {
      glowIntensity -= 0.5;
      if (glowIntensity < 5) glowIncreasing = true;
    }
}

void handleMouse() 
{
  if (htmlPlaceholder.isClicked()) 
  {
    println("HTML content button clicked!");
    println("latitude :" + sensorData.latitude + "  longitude: " + sensorData.longitude);
    startServer();
  }
  else if (publishData.isClicked())
  {
    /*
      Gets location only if location not fetched yet (to limit non-free API calls)
      readSerial() grabs location from the global var.
      Appends data to the file.
    */

    if (location == null) location = fetchLocation();

    appendSensorData(readSerial());// Trigger popup message
    popupMessage = "Data Published";
    showPopup = true;
    popupStartTime = millis();
  }
}


 void handleKeyboard() {
    // No keyboard actions for this screen
  }
  
void drawShadowBoxImage(int x, int y, int w, int h, int cornerRadius, color boxColor, color shadowColor, PImage backgroundImage) {
    if (backgroundImage != null) {
        // Resize the image to match the rectangle dimensions
        PImage resizedImage = backgroundImage.copy();
        resizedImage.resize(w, h);

        // Create a mask with rounded corners
        PGraphics mask = createGraphics(w, h);
        mask.beginDraw();
        mask.background(0); // Black background
        mask.fill(255);     // White for the rounded rectangle
        mask.noStroke();
        mask.rect(0, 0, w, h, cornerRadius);
        mask.endDraw();

        // Apply the mask to the resized image
        resizedImage.mask(mask);

        // Draw the masked image inside the rectangle
        image(resizedImage, x, y);
    } else {
        // Fallback color if image is not available
        fill(boxColor);
        rect(x, y, w, h, cornerRadius);
    }

    // Outer glowing outline (soft glow effect)
    for (int i = 8; i > 0; i--) { // Multiple layers for a soft glow
        stroke(lerpColor(color(30, 30, 30), color(94, 156, 255), i / 8.0)); // Glow gradient
        strokeWeight(i * 0.7); // Gradual thickness
        noFill();
        rect(x, y, w, h, cornerRadius);
    }

    // Main metallic phone-like outline
    stroke(color(50, 50, 50)); // Dark metallic outline
    strokeWeight(4); // Main outline thickness
    noFill();
    rect(x, y, w, h, cornerRadius);
}



void drawPrettyTitle(String text, float x, float y) {
    PFont titleFont = createFont("Arial Black", 60, true); // Thicker and bold font
    textFont(titleFont);
    textAlign(CENTER, CENTER);
    textSize(60);

    // Animated Glow Effect
    for (int glow = (int) glowIntensity; glow > 0; glow--) {
      stroke(lerpColor(color(94, 156, 255), color(255, 255, 255), glow / glowIntensity)); // Vibrant blue-white glow
      strokeWeight(glow * 0.5f); // Gradually thicker glow
      noFill();
      text(text, x, y);
    }

    // Foreground vibrant text
    fill(255, 223, 186); // Light orange for contrast
    noStroke();
    text(text, x, y);
  }
 
 

void showPopupMessage() {
  if (showPopup) {
    int popupWidth = width - 40; // Popup width with padding
    int popupHeight = 50; // Popup height
    int popupX = 20; // Centered with padding
    int popupY = 20; // Top margin

    // Draw popup rectangle
    fill(50, 50, 50, 200); // Semi-transparent dark background
    noStroke();
    rect(popupX, popupY, popupWidth, popupHeight, 10); // Rounded rectangle

    // Draw message text
    fill(255); // White text
    textAlign(CENTER, CENTER);
    textSize(20);
    text(popupMessage, popupX + popupWidth / 2, popupY + popupHeight / 2);

    // Hide popup after duration
    if (millis() - popupStartTime > popupDuration) {
      showPopup = false;
    }
  }
}
}



  
