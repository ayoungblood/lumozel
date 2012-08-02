

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
  private int xPos;
  private int yPos;
  private int displayWidth;
  private int displayHeight;
  private String[] contents;
  private int contentsPointer;
  private color textColor;
  
  LMDisplayList(int x, int y) {
    xPos = x;
    yPos = y;
    displayWidth = 160;
    displayHeight = 80;
    // TODO: Set list contents length based on displayHeight/line height
    contents = new String[5];
    for (int i=0; i < contents.length; i++) {
      contents[i] = "";
    }
    textColor = color(255); // The default text color
  }
  
  void draw() {
    fill(textColor);
    for (int i=0; i < contents.length; i++) {
      // TODO: Truncate string length if pixel length is greater than displayWidth
      text(contents[i], xPos+2, yPos + (textDescent()+textAscent())*(i+1)-2);
    }
  }
  
  void addLine(String s) {
    contents[contentsPointer] = s;
    contentsPointer ++;
    if (contentsPointer > contents.length-1) {
      contentsPointer = 0;
    }
  }
  String getLine(int index) {
    return contents[index];
  }
  void setPosition(int x, int y) {
    xPos = x;
    yPos = y;
  }
  int[] getPosition() {
    int[] pos = new int[2];
    pos[0] = xPos;
    pos[1] = yPos;
    return pos;
  }
  void setWidth(int w) {
    displayWidth = w;
  }
  int getWidth() {
    return displayWidth;
  }
  void setHeight(int h) {
    displayHeight = h;
  }
  int getHeight() {
    return displayHeight;
  }
  void setTextColor(color c) {
    textColor = c;
  }
  color getTextColor() {
    return textColor;
  }
}
  
  
