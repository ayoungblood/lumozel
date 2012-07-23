import processing.serial.*;
import cc.arduino.*;
import processing.opengl.*;

/**************************************************************************
 * arduinoDistanceGrapher.
 * Displays the distance given by a Sharp GP2Y0A21YK in realtime graph form.
 * Using OPENGL for high framerates
 * Author: Akira Youngblood
 * Development Begun 2012-08-22
 **************************************************************************/

Arduino arduino;
int xPos = 50;
int pinOfInterest = 0;

float calibrate = 14750; // typically 12343.85

void setup() {
  size(1000,1200,OPENGL);
  frameRate(240);
  
  println(Arduino.list());
  arduino = new Arduino(this,Arduino.list()[0], 57600);
  redrawBaseGraphics();
}
void draw() {
  fill(255);
  stroke(#00ff00);
  rect(xPos, 1200-map(calibrate * pow(arduino.analogRead(pinOfInterest),-1.15),0,60,0,1200), 1,1);
  fill(0); noStroke();
  rect(width-50,0,50,200);
  fill(255);
  text((int)frameRate,width-45,20);
  text(xPos,width-45, 45);
  text(arduino.analogRead(pinOfInterest),width-45,70);
  text( calibrate * pow(arduino.analogRead(pinOfInterest), -1.15), width-45, 95);
  xPos++;
  if (xPos > width-50) {
    xPos = 50;
    redrawBaseGraphics();
  }
  
}

void redrawBaseGraphics() {
  background(0);
  stroke(127);
  for (int i=0; i<=60; i++) {
    line(50,1200-20*i,width-50,1200-20*i);
    text(i,10,1200-20*i);
  }
}
