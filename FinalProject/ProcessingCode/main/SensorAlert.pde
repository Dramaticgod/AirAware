class SensorAlert {
    HashMap<String, Boolean> triggeredMap = new HashMap<>();
    HashMap<String, Integer> triggerTimeMap = new HashMap<>();
    HashMap<String, Float> thresholdsMap = new HashMap<>(); // Store thresholds for each sensor

    // Constructor
    SensorAlert() {
        // No initialization required
    }

    void checkThreshold(String label, float value, float threshold, int x, int y, int boxWidth, int boxHeight, int cornerRadius, color normalColor, color outlineColor, String units) {
        thresholdsMap.put(label, threshold); // Store threshold for the label
        handleThreshold(label, value, threshold, x, y, boxWidth, boxHeight, cornerRadius, normalColor, outlineColor, true, units);

        // Check if the box is clicked
        if (isBoxClicked(x, y, boxWidth, boxHeight)) {
            showThresholdPopup(label, threshold, units);  // Display threshold information
        }
    }

    private void handleThreshold(String label, float value, float threshold, int x, int y, int boxWidth, int boxHeight, int cornerRadius, color normalColor, color outlineColor, boolean isFloat, String units) {
        if (!triggeredMap.containsKey(label)) {
            triggeredMap.put(label, false);
            triggerTimeMap.put(label, 0);
        }

        if (value > threshold && !triggeredMap.get(label)) {
            triggeredMap.put(label, true);
            triggerTimeMap.put(label, millis());
            play_music(); // Play alert sound
        }

        if (triggeredMap.get(label)) {
            if (millis() - triggerTimeMap.get(label) < 5000) {
                // Draw shaking red box with rounded borders
                drawShakingBox(x, y, boxWidth, boxHeight, cornerRadius, color(255, 0, 0), outlineColor);
            } else {
                // Reset after 5 seconds
                triggeredMap.put(label, false);
            }
        } else {
            // Draw normal box with rounded borders
            drawEnhancedBox(x, y, boxWidth, boxHeight, cornerRadius, normalColor, outlineColor);
        }

        // Draw sensor label and value inside the box
        if (isFloat) {
            drawSensorText(label, value, x, y, boxWidth, boxHeight, units, normalColor);
        } else {
            drawSensorText(label, (int) value, x, y, boxWidth, boxHeight, units, normalColor);
        }
    }

    void drawShakingBox(int x, int y, int w, int h, int cornerRadius, color boxColor, color outlineColor) {
        int shakeX = (int) random(-3, 3); // Less aggressive shaking
        int shakeY = (int) random(-3, 3);

        // Add gradient effect for the shaking box
        PGraphics gradient = createGraphics(w, h);
        gradient.beginDraw();
        for (int i = 0; i < h; i++) {
            float inter = map(i, 0, h, 0, 1);
            gradient.stroke(lerpColor(boxColor, color(255, 100, 100), inter));
            gradient.line(0, i, w, i);
        }
        gradient.endDraw();
        PImage roundedGradient = applyRoundedCorners(gradient, cornerRadius);
        image(roundedGradient, x + shakeX, y + shakeY);

        // Draw red border for shaking effect
        noFill();
        stroke(color(255, 50, 50)); // Bright red for shaking outline
        strokeWeight(3);
        rect(x + shakeX, y + shakeY, w, h, cornerRadius);
    }

    void drawEnhancedBox(int x, int y, int w, int h, int cornerRadius, color boxColor, color outlineColor) {
        // Add gradient effect
        PGraphics gradient = createGraphics(w, h);
        gradient.beginDraw();
        for (int i = 0; i < h; i++) {
            float inter = map(i, 0, h, 0, 1);
            gradient.stroke(lerpColor(boxColor, color(255), inter));
            gradient.line(0, i, w, i);
        }
        gradient.endDraw();
        PImage roundedGradient = applyRoundedCorners(gradient, cornerRadius);
        image(roundedGradient, x, y);

        // Draw subtle rounded border
        noFill();
        stroke(outlineColor);
        strokeWeight(2); // Minimalistic border
        rect(x, y, w, h, cornerRadius);

        // Add shadow for depth
        fill(0, 0, 0, 50); // Semi-transparent black shadow
        noStroke();
        rect(x + 3, y + 3, w, h, cornerRadius); // Slight offset for shadow
    }

    void drawSensorText(String label, float value, int x, int y, int boxWidth, int boxHeight, String units, color backgroundColor) {
        textAlign(CENTER, CENTER);
        textSize(14); // Clean spacing

        // Choose contrasting font color based on the background
        if (brightness(backgroundColor) > 128) {
            fill(0); // Dark font for light backgrounds
        } else {
            fill(255); // Light font for dark backgrounds
        }
        text(label, x + boxWidth / 2, y + 20); // Sensor label

        textSize(18);
        text(nf(value, 0, 2) + " " + units, x + boxWidth / 2, y + boxHeight / 2 + 10); // Float value with 2 decimals
    }

    // Check if the box is clicked
    boolean isBoxClicked(int x, int y, int boxWidth, int boxHeight) {
        return mousePressed && mouseX > x && mouseX < x + boxWidth && mouseY > y && mouseY < y + boxHeight;
    }

    // Show popup with threshold information and consequences
    // Show threshold message as a top rectangle above the sensor box
void showThresholdPopup(String label, float threshold, String units) {
    String consequenceMessage = getConsequenceMessage(label); // Get the consequence message

    // Construct the popup message
    String message = nf(threshold, 0, 2) + " " + units + " > " + consequenceMessage;

    // Define the dimensions of the top rectangle
    int popupWidth = width - 40; // Slight padding from the screen edges
    int popupHeight = 40; // Height of the popup
    int popupX = 20; // Centered horizontally with padding
    int popupY = 10; // Top padding from the screen

    // Draw the rectangle for the message
    fill(0, 0, 0, 200); // Semi-transparent black background
    rect(popupX, popupY, popupWidth, popupHeight, 10); // Top-aligned rectangle

    // Display the message
    fill(255); // White text
    textAlign(CENTER, CENTER);
    textSize(16); // Slightly larger for visibility
    text(message, popupX + popupWidth / 2, popupY + popupHeight / 2); // Center text inside the rectangle
}



    // Get consequence message for each sensor
    String getConsequenceMessage(String label) {
        switch (label) {
            case "Temperature":
                return "Heatstroke Warning";
            case "Humidity":
                return "High humidity";
            case "CO2":
                return "Drowsiness and poor air.";
            case "TVOC":
                return "Bad indoor air quality.";
            case "Dust":
                return "Triggers allergies.";
            case "CO":
                return "Life-threatening.";
            default:
                return "Exceeding this threshold is harmful.";
        }
    }

    // Helper to apply rounded corners to a PGraphics object
    PImage applyRoundedCorners(PGraphics pg, int cornerRadius) {
        PGraphics mask = createGraphics(pg.width, pg.height);
        mask.beginDraw();
        mask.background(0); // Black background for mask
        mask.fill(255); // White rounded rectangle
        mask.noStroke();
        mask.rect(0, 0, pg.width, pg.height, cornerRadius);
        mask.endDraw();

        PImage img = pg.get();
        img.mask(mask.get());
        return img;
    }
}
