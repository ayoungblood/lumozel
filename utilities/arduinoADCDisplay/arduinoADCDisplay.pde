import cc.arduino.*;
import processing.serial.*;
import processing.opengl.*;

/******************************************************************************
 * Simple sketch displaying the values of all the Arduino analog pins
 * Also displays the corresponding distance for a connected Sharp GP GP2Y0A21YK
 * Author: Akira Youngblood
 * Development Begun 2012-07-22
 ******************************************************************************/

PFont font;
Arduino arduino;
int[] pins;
RangerAverage avg;

int numberOfPins = 8; // Typ. 6, 8 for Mini & Nano, 16 for Mega
void setup() {
  size(numberOfPins*73+120,400,OPENGL);
  smooth();
  frameRate(120);
  font = createFont("Courier",18);
  textFont(font);
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  pins = new int[numberOfPins];
  avg = new RangerAverage(arduino, numberOfPins, 5);
}
void draw() {
  background(0);
  fill(#00FF00);  
  text("   PIN", 15, 25);
  text("   ADC", 15, 65);
  text("   VDC", 15, 105);
  text("RAW-CM", 15, 145);
  text("RAW-IN", 15, 185);
  text("T MEAN", 15, 225);
  text("UPDATE RATE: " + (int)frameRate + "Hz", 15, height-20);
  
  avg.update();
  
  for (int i=0; i < numberOfPins; i++) {
    text("A"+i, 70*i+120, 25);
  }
  
  for (int i=0; i < numberOfPins; i++) {
    pins[i] = arduino.analogRead(i);
  }
  
  for (int i=0; i < numberOfPins; i++) {
    text(pins[i], 70*i+120, 65);
  }
  
  for (int i=0; i < numberOfPins; i++) {
    text( nf(map(pins[i],0,1023,0,5),1,2) , 70*i+120, 105);
  }
  
  for (int i=0; i < numberOfPins; i++) {
    text( nf(12343.85 * pow(pins[i],-1.15),2,1) , 70*i+120, 145);
  }
  
  for (int i=0; i < numberOfPins; i++) {
    text( nf(2.54*(12343.85 * pow(pins[i],-1.15)),2,1) , 70*i+120, 185);
  }
  
  for (int i=0; i < numberOfPins; i++) {
    text( nf(avg.getMean(i),4,-1), 70*i+120, 225);
  }
  
}

class RangerAverage {
  private Arduino arduino;
  private int numOfPins;
  private float[] averages;
  int sampleCount;
  private int index;
  private int[][] readings;
  RangerAverage(Arduino a, int n, int s) {
    arduino = a;
    numOfPins = n;
    sampleCount = s;
    averages = new float[numOfPins];
    for (int i=0; i < numOfPins; i++) {
      averages[i] = 0;
    }
    readings = new int[numOfPins][sampleCount];
    for (int i=0; i < numOfPins; i++) {
      for (int j=0; j < sampleCount; j++) {
        readings[i][j] = 0;
      }
    }
    index = 0;
  }
  void update() {
    for (int i=0; i < numOfPins; i++) {
      readings[i][index] = arduino.analogRead(i);
    }
    index ++;
    if (index >= sampleCount) {
      index = 0;
    }
  }
  float getMean(int pin) {
    float sum = 0;
    for (int i=0; i<sampleCount; i++) {
      sum += readings[pin][i];
    }
    return sum/sampleCount;
  }
}
