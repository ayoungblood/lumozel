import controlP5.*;
import cc.arduino.*;
import processing.serial.*;
import rwmidi.*;

// Basic sketch handling four capacitive touch sensors implemented via Arduino pins
// User configurable MIDI output patching
// Using lots of threads to keep the Animation Thread clean
// Author: Akira Youngblood  Date: 2012-09-13

Arduino arduino;
ControlP5 cp5;
SensorLump sensors;

void setup() {
  size(200,200);
  frameRate(30); // Because we are using other threads, the Animation Thread can run slow
  
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  
  cp5 = new ControlP5(this);
  int[] ps = {3,4,5,6};
  sensors = new SensorLump(arduino, ps);
}

void draw() {
  background(0);
  
  
  
}

class SensorLump {
  int[] pins;
  boolean[] states;
  Arduino ar;
  SLThread[] jobs;
  
  SensorLump(Arduino a, int[] ps) {
    int[] pins = ps;
    ar = a;
    for (int i=0; i < pins.length; i++) {
      jobs[i] = new SLThread(pins[i]);
      jobs[i].start();
    }
  }
  
  boolean get(int dx) {
    return jobs[dx].pressed;
  }
  
  class SLThread extends Thread {
    boolean running;
    int pin;
    int count = 0;
    boolean pressed = false;
    SLThread(int p) {
      pin = p;
      running = false;
    }
    @Override
    void run() {
      while (running) {
        count = 0;
        ar.pinMode(pin, Arduino.OUTPUT);
        ar.digitalWrite(pin, Arduino.HIGH);
        try {
          sleep(1);
        } catch (InterruptedException e) {
          // No one cares
        }
        ar.digitalWrite(pin, Arduino.LOW);
        ar.pinMode(pin, Arduino.INPUT);
        try {
          sleep(1);
        } catch (InterruptedException e) {
          // No one cares
        }
        while (ar.digitalRead(pin) == Arduino.HIGH) {
          count ++;
          try {
          sleep(1);
        } catch (InterruptedException e) {
          // No one cares
        }
          if (count > 5) {
            pressed = true;
          }
        } 
      }
    }
    @Override
    void start() {
      running = true;
      super.start();
    }
    void quit() {
      running = false;
      interrupt();
    }
  }
}
