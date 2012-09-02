import cc.arduino.*;
import processing.serial.*;
import controlP5.*;
import rwmidi.*;

/****************************************************************************\
 * Simple Lumozel Interface for Single-Beam Testing
 * This sketch provides full functionality for a single beam, albeit with a
 * very limited GUI/parameter control, and only MIDI communication.
 * 
 * License: TODO: Find license
 * Author: Akira Youngblood
\****************************************************************************/

ControlP5 cp5;
Arduino arduino;
MidiOutput midiOut;
int midiOutIndex = 0;
Average ranger, laser;
boolean noteTriggered = false;
int lastNoteTriggered = 0;



void setup() {
  size(640,480,P2D);
  smooth();
  frameRate(480);
  textMode(SCREEN);
  setupArduino();
  setupMidi();
  ranger = new Average(arduino, 0, 15);
  laser = new Average(arduino, 1, 5);
  
}
void draw() {
  background(0);
  float distance = 12343.85*pow(ranger.calculateMedian(),-1.15);
  if (laser.calculateMedian() < 256) {
    if (noteTriggered == false) {
      lastNoteTriggered = constrain(48+floor((distance-10)/3),0,127);
      midiOut.sendNoteOn(1,lastNoteTriggered,90);
      noteTriggered = true;
    }
  }
  else {
    if (noteTriggered == true) {
      midiOut.sendNoteOff(1,lastNoteTriggered,90);
      noteTriggered = false;
    }
  }
  text("distance: " + distance, 20, 25);
  text("noteTriggered: " + new Boolean(noteTriggered).toString(), 20, 45);
  text("lastNoteTriggered: " + lastNoteTriggered, 20, 65);
  text("laser: " + arduino.analogRead(1), 20, 85);
  text("framerate: " + frameRate, 20, 105);
}

class Average {
  Arduino ar;
  int pin;
  final int avgLength;
  final int miavgLength;
  float[] rawInput;
  float[] medianInput;
  int index;
  int miindex;
  
  Average(Arduino a, int p, int avgLen) {
    ar = a;
    pin = p;
    avgLength = avgLen;
    miavgLength = 20;
    rawInput = new float[avgLength];
    for (int i=0; i<rawInput.length; i++) {
      rawInput[i] = 0;
    }
    medianInput = new float[miavgLength];
    index = 0;
    miindex = 0;
  }
  // calculateMedian() updates the float array, then recalculates and returns the average
  float calculateMedian() {
    rawInput[index] = ar.analogRead(pin);
    index++;
    if (index >= avgLength) {
      index = 0;
    }
    float[] process = rawInput;
    Arrays.sort(process);
    return (process[(int)(avgLength/2)] + process[1+(int)(avgLength/2)])/2.00f;
  }
  // calculateMean() updates the float array, then recalculates and returns the average
  float calculateMean() {
    // TODO: implement this. Note that this method is of limited use..
    println("Do not use Average.calculateMean()!");
    return 0.0f;
  }
  float calculateMeanMedian() {
    medianInput[miindex] = calculateMedian();
    miindex ++;
    if (miindex >= medianInput.length) {
      miindex = 0;
    }
    float sum = 0;
    for (int i=0; i > medianInput.length; i++) {
      sum += medianInput[i];
    }
    return sum/miavgLength;
  }
  
}
void mousePressed() {
  
}

void setupArduino() {
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  println("Using Arduino at: " + Arduino.list()[0]);
}
void setupMidi() {
  println(RWMidi.getOutputDevices());
  midiOut = RWMidi.getOutputDevices()[midiOutIndex].createOutput();
  println("Using "+RWMidi.getOutputDevices()[midiOutIndex]+" for MIDI output");
}
void panicMidi() {
  for (int ch=0;ch<16;ch++) {
    for (int nt=0;nt<128;nt++) {
        midiOut.sendNoteOff(ch,nt,63);
    }
  }
}

// @Override PApplet.exit()
void exit() {
  midiOut.closeMidi();
  super.stop();
  System.exit(0);
}

