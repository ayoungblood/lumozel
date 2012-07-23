import cc.arduino.*;
import processing.serial.*;
import processing.opengl.*;

// Simple sketch displaying the values of all the Arduino analog pins


PFont font;
float charHeight, charWidth;
Arduino arduino;
int[] pins = new int[8];

void setup() {
  size(640,400,OPENGL);
  smooth();
  font = createFont("Courier",18);
  textFont(font);
  charHeight = textAscent() + textDescent();
  charWidth = textWidth("Q");
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  
}
void draw() {
  background(0);
  fill(#00FF00);  
  text("PIN", 15, 25);
  text("ADC", 15, 65);
  text("VDC", 15, 105);
  text("CM", 15+charWidth, 145);
  
  for (int i=0; i < 8; i++) {
    text("A"+i, 70*i+80, 25);
  }
  
  for (int i=0; i < 8; i++) {
    pins[i] = arduino.analogRead(i);
  }
  
  for (int i=0; i < 8; i++) {
    text(pins[i], 70*i+80, 65);
  }
  
  for (int i=0; i < 8; i++) {
    text( nf(map(pins[i],0,1023,0,5),1,2) , 70*i+80, 105);
  }
  
  for (int i=0; i < 8; i++) {
    text( nf(12343.85 * pow(pins[i],-1.15),2,1) , 70*i+80, 145);
  }
  
}
