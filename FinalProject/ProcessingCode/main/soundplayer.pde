import processing.sound.*;

SoundFile Warning;
int lastPlayedTime = -1; // Tracks the last time the sound was played (-1 means it hasn't played yet)
int soundInterval = 120000; // 2 minutes in milliseconds

void setup_sound() {
  Warning = new SoundFile(this, "warning.wav");
}

void play_music() {
  int currentTime = millis();
  
  // Always play the first time, then enforce the interval
  if (lastPlayedTime == -1 || currentTime - lastPlayedTime >= soundInterval) {
    Warning.play();
    lastPlayedTime = currentTime; // Update the last played time
  }
}

void stop_music() {
  Warning.stop();
}
