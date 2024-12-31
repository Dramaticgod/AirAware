import processing.serial.*;

/*

 Class for picking the valid port at the start of the program.
 
 Because processing is weird, to use it you need to include following lines in the main program code:
 
 Serial myPort;
 SerialPortPicker portPicker;
 
 void setup()
 {
 size(1200, 950); //just an example
 portPicker = new SerialPortPicker(10, 10);
 }
 
 void draw()
 {
 portPicker.draw();
 }
 
 void mousePressed()
 {
 int selectedPort = portPicker.mouseEvent();
 
 if(selectedPort == -2)
 {
 println("Selected working in demo mode");
 }
 else if (selectedPort >= 0)
 {
 print("Selected port '");
 print(portPicker.serialPorts[selectedPort]);
 println("'");
 }
 }
 
 
 */


class SerialPortPicker
{
  String[] serialPorts;
  Button[] buttons;
  int posX, posY;
  color backgroundColorInactive = color(50, 50, 50);
  color backgroundColorMouseOver = color(25, 25, 25);
  color buttonTextColor = color(255, 255, 255);

  SerialPortPicker(int posX, int posY)
  {
    serialPorts = Serial.list();
    serialPorts = append(serialPorts, "Demo mode");

    buttons = new Button[serialPorts.length];
    this.posX = posX;
    this.posY = posY;

    for (int i = 0; i < serialPorts.length; i++)
    {
      buttons[i] = new Button(posX, 40 + posY + 40 * (i + 1), 300, 30, serialPorts[i], backgroundColorInactive, buttonTextColor);
    }
  }

  void draw()
  {
    boolean cursorAsHand = false;

    fill(0, 0, 0);
    textSize(40);
    textAlign(LEFT);
    text("Available ports: ", posX, posY + 40);

    for (int i = 0; i < serialPorts.length; i++)
    {
      /*
        Checking only if mouse hovers over the button,
       but isClicked works the same.
       
       Change button background if mouse hovers over it and change cursor.
       */
      if (buttons[i].isClicked())
      {
        cursorAsHand = true;
        buttons[i].bgColor = backgroundColorMouseOver;
      } else
      {
        buttons[i].bgColor = backgroundColorInactive;
      }

      buttons[i].display();
    }

    if (cursorAsHand)
    {
      cursor(HAND);
    } else
    {
      cursor(ARROW);
    }
  }

  /*

   It returns the index of String serialPorts[] array of which port was selected.
   
   If returns -1, no valid port was selected (mouse clicked outside the bounds).
   If returns -2, then working in demo mode.
   
   Use code like:
   
   int selectedPort = thisClassName.mouseEvent();
   if (selectedPort != -1)
   {
   print("Port: " + thisClassName.serialPorts[selectedPort]);
   
   Serial myPort = new Serial(this, thisClassName.serialPorts[selectedPort], 9600);
   }
   
   Oh boy processing is something...
   
   */
  int mouseEvent()
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if (buttons[i].isClicked())
      {
        if (i == buttons.length - 1) return -2;

        return i;
      }
    }

    return -1;
  }
}
