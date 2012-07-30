import processing.serial.*;
import cc.arduino.*;

import processing.opengl.*;

/* Template for Processing sketches using an Arduino with Firmata
 *
 */

public final int ARDUINO_SERIAL_INDEX = 0; // The index of the serial device that is the Arduino

Arduino arduino;

void setup() {
  size(640,480,OPENGL); // OpenGL is used to get a higher sampling rate/more responsive sketch
  smooth();
  frameRate(240);
  
  // Setup the Arduino
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[ARDUINO_SERIAL_INDEX], 57600);
  
}

void draw() {
  background(0);
  
}
