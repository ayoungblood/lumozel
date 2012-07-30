import processing.serial.*;
import cc.arduino.*;

import processing.opengl.*;

/* Template for Processing sketches using an Arduino with Firmata
 *
 */

public final int ARDUINO_SERIAL_INDEX = 2; // The index of the serial device that is the Arduino
Arduino arduino;

int counter = 0;

void setup() {
  size(640,480,OPENGL); // OpenGL is used to get a higher sampling rate/more responsive sketch
  smooth();
  frameRate(240);
  
  // Setup the Arduino
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[ARDUINO_SERIAL_INDEX], 57600);
  
  fill(#00ff00); noStroke();
}

void draw() {
  background(0);
  
  arduino.pinMode(10,Arduino.OUTPUT);
  arduino.digitalWrite(10,Arduino.HIGH);
  delay(2);
  arduino.pinMode(10, Arduino.INPUT);
  
  while (arduino.digitalRead(10) == Arduino.HIGH) {
    counter ++;
    
  }
  rect(20,20,20,counter);
  text(counter,40,20);
  
  
  counter = 0;
}
