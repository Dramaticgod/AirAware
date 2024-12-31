import processing.core.PFont;

class InputScreen extends Screen {
  String nameInput = "";
  boolean dustAllergy = false;
  boolean typingName = false;
  Button submitButton;
  float glowIntensity = 0; // For animated glow effect
  boolean glowIncreasing = true;

  // Constructor
  InputScreen() {
    submitButton = new Button(width / 2 - 100, height / 2 + 130, 200, 60, "Login", color(30, 136, 229), color(255)); // Larger button
  }

  void display() {
    // Load a thicker font for the UI
    PFont boldFont = createFont("Arial Black", 28, true); // Thicker and more readable
    textFont(boldFont);

    background(35); // Placeholder background

    // Draw phone-like rectangle
    fill(240);
    drawShadowBoxImage(width / 2 - 160, height / 2 - 300, 320, 600, 20, color(255), color(200, 200, 200, 100), boxBackgroundImage);

    // Title: "AirAware"
    drawPrettyTitle("AirAware", width / 2, height / 2 - 200); // Adjusted for smaller screen

    // Name input box with a subtle dark outline
    drawOutlinedBox(width / 2 - 150, height / 2 - 90, 300, 50, 10, color(255), color(180)); // Adjusted for smaller screen
    fill(100); // Soft white for readability
    textAlign(LEFT, CENTER);
    textSize(18); // Adjusted font size for input placeholder
    text(nameInput.isEmpty() ? "Enter your name..." : nameInput, width / 2 - 140, height / 2 - 65); // Aligned with box

    // Dust allergy toggle
    drawRoundedCheckbox(width / 2 - 150, height / 2 + 10, 20, dustAllergy); // Adjusted for smaller screen
    fill(240); // Soft white for visibility
    textAlign(LEFT, CENTER);
    textSize(22); // Increased font size for toggle label
    text("Allergic to Dust", width / 2 - 120, height / 2 + 20);

    // Submit button
    submitButton.display();

    // Update glow intensity for animation
    if (glowIncreasing) {
      glowIntensity += 0.5;
      if (glowIntensity > 100) glowIncreasing = false;
    } else {
      glowIntensity -= 0.5;
      if (glowIntensity < 5) glowIncreasing = true;
    }
  }

  void handleMouse() {
    // Check if name input box is clicked
    if (mouseY > height / 2 - 90 && mouseY < height / 2 - 40 && mouseX > width / 2 - 150 && mouseX < width / 2 + 150) {
      typingName = true; // Focus on name input
    } else {
      typingName = false;
    }

    // Toggle dust allergy
    if (mouseX > width / 2 - 150 && mouseX < width / 2 - 130 && mouseY > height / 2 + 10 && mouseY < height / 2 + 30) {
      dustAllergy = !dustAllergy; // Toggle allergy status
    }

    // Handle submit button click
    if (submitButton.isClicked()) {
      user.name = nameInput.isEmpty() ? "Guest" : nameInput;
      user.allergicToDust = dustAllergy;
      stateManager = 1; // Switch to DataScreen
      currentScreen = new DataScreen();
    }
  }

  void handleKeyboard() {
    if (typingName) {
      if (key == BACKSPACE && nameInput.length() > 0) {
        nameInput = nameInput.substring(0, nameInput.length() - 1);
      } else if (key != CODED && key != ENTER) {
        nameInput += key;
      }
    }
  }


  // Helper to draw a shadowed box
  void drawOutlinedBox(int x, int y, int w, int h, int cornerRadius, color boxColor, color outlineColor) {
    stroke(outlineColor);
    strokeWeight(1.5); // Subtle dark outline
    fill(boxColor);
    rect(x, y, w, h, cornerRadius);
    noStroke();
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


  // Helper to draw a rounded checkbox with proper alignment
  void drawRoundedCheckbox(int x, int y, int size, boolean isChecked) {
    fill(255);
    rect(x, y, size, size, 5); // Rounded rectangle
    if (isChecked) {
      fill(76, 175, 80); // Green for checked
      ellipse(x + size / 2, y + size / 2, size - 6, size - 6); // Circle inside
    }
  }

  // Helper to draw a pretty title with animated glow
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
}
