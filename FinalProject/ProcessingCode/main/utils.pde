import java.awt.Desktop;
import java.io.File;
import java.net.URI;
import java.net.URL;

String SENSOR_DATA_PATH = "yourPath";
void appendSensorData(SensorData data) 
{
  JSONArray dataArray;
  println("JSON FILE PATH : " + SENSOR_DATA_PATH);

  // Load existing data if the file exists
  File jsonFile = new File(SENSOR_DATA_PATH);

  if (jsonFile.exists() && !jsonFile.isDirectory()) 
  {
    try 
    {
      dataArray = loadJSONArray(SENSOR_DATA_PATH);
      println("Existing data loaded: " + dataArray.size() + " entries.");
    } 
    catch (Exception e) 
    {
      println("Error loading JSON file: " + e.getMessage());
      dataArray = new JSONArray();
    }
  } 
  else 
  {
    println("No existing file found. Creating a new array.");
    dataArray = new JSONArray();
  }

  // Create a new JSON object for the current data
  JSONObject json = new JSONObject();
  json.setString("user", user.name);

  json.setInt("temperature", data.temperature);
  json.setInt("humidity", data.humidity);
  json.setInt("dust", data.dust);

  json.setInt("co2", data.co2);
  json.setInt("tvoc", data.tvoc);
  
  json.setInt("co", data.co);
  json.setInt("nh3", data.nh3);
  json.setInt("no2", data.no2);
  
  json.setDouble("latitude", data.latitude);
  json.setDouble("longitude", data.longitude);

  json.setInt("year", year());
  json.setInt("month", month());
  json.setInt("day", day());
  json.setInt("hour", hour());
  json.setInt("minute", minute());
  json.setInt("second", second());

  // Append the new data to the array
  println("Appending new data: " + json.toString());
  dataArray.append(json);

  // Save the updated array back to the file
  try 
  {
    println("Saving dataArray with " + dataArray.size() + " entries.");
    saveJSONArray(dataArray, SENSOR_DATA_PATH);
    println("Sensor data appended to: " + SENSOR_DATA_PATH);
  } 
  catch (Exception e) 
  {
    println("Error saving JSON file: " + e.getMessage());
  }

  println("");
}


// Starting the html script on click, needs pre existing python server running in the same directory as the html file 
// once in the directory, use command python -m http.server 8000
void startServer() {
  try {
    // Define the URL
    String url = "http://127.0.0.1:8000/map.html";

    // Use Runtime to execute the command to open the URL
    String command;

    // For Windows
    if (System.getProperty("os.name").toLowerCase().contains("win")) {
      command = "cmd /c start " + url;
    }
    // For macOS
    else if (System.getProperty("os.name").toLowerCase().contains("mac")) {
      command = "open " + url;
    }
    // For Linux
    else {
      command = "xdg-open " + url;
    }

    // Execute the command
    Process process = Runtime.getRuntime().exec(command);

    // Print confirmation
    println("Opening: " + url);
  } catch (Exception e) {
    println("Error launching URL: " + e.getMessage());
    e.printStackTrace();
  }
}

float[] fetchLocation() {
  if(true)
  {
    println("Returning hard-coded location data, check utils.pde file.");
    return new float[] {42.031464, -87.92673};
  }
  
  try {
    String apiKey = "yourAPI"; 
    String url = "https://www.googleapis.com/geolocation/v1/geolocate?key=" + apiKey;

    // POST request to Geolocation API
    PostRequest post = new PostRequest(url);
    post.addHeader("Content-Type", "application/json");
    post.addData("{\"considerIp\": true}"); // Payload with considerIp
    post.send();

    // Parse the response
    JSONObject json = parseJSONObject(post.getContent());
    println("API Response: " + post.getContent()); // Debugging purposes

    if (json != null && json.hasKey("location")) {
      JSONObject location = json.getJSONObject("location");
      float latitude = location.getFloat("lat");
      float longitude = location.getFloat("lng");

      // Include accuracy in the log
      if (json.hasKey("accuracy")) {
        float accuracy = json.getFloat("accuracy");
        println("Accuracy: " + accuracy + " meters");
      }

      println("Location fetched: Latitude " + latitude + ", Longitude " + longitude);
      return new float[] {latitude, longitude};
    } else {
      println("Error: Invalid response from API.");
      return new float[] {0.0, 0.0}; // Default to 0 if the API fails
    }
  } catch (Exception e) {
    println("Error fetching location: " + e.getMessage());
    return new float[] {0.0, 0.0};
  }
}
