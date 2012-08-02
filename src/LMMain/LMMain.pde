

/****************************************************************************\
 * Main Lumozel Software Interface
 * 
 * 
 * 
 * License:
 * Author: Akira Youngblood
\****************************************************************************/



void setup() {
  size(1024,768);
  smooth();
  frameRate(60);
  
  
}

void draw() {
  background(0);
  
}

// Overriding the P5 exit method, because we need to shut down all modules properly.
void exit() {
  
  
  // System
  super.stop();
  println( millis() + ": super.stop() called. User must destroy window.");
}


// LMDisplayList class
class LMDisplayList {
  private int xPos; // The xPos & yPos describe the left-upper corner of where the list is displayed
  private int yPos;
  private int displayWidth;
  private int displayHeight;
  private String[] contents;
  private int contentsPointer;
  
  LMDisplayList(int x, int y) {
    xPos = x;
    yPos = y;
    displayWidth = 160;
    displayHeight = 80;
    // Initialize contents. Need a way to set length based on displayHeight
    contents = new String[5];
    for (int i=0; i < contents.length; i++) {
      contents[i] = "";
    }
  }
  
  void draw() {
    for (int i=0; i < contents.length; i++) {
      text(contents[i], xPos, yPos + (textDescent()+textAscent())*(i+1));
    }
  }
  
  void addLine(String s) {
    contents[contentsPointer] = s;
    contentsPointer ++;
  }
  void setPosition(int x, int y) {
    xPos = x;
    yPos = y;
  }
  void setWidth(int w) {
    displayWidth = w;
  }
  void setHeight(int h) {
    displayHeight = h;
  }
}
  
  
