import cc.arduino.*;
import processing.serial.*;
import controlP5.*;
import rwmidi.*;

/****************************************************************************\
 * Provides minimal functionality for two beams, for debugging purposes
 * MIDI output only
 * 
 * License: TODO: Find license
 * Author: Akira Youngblood
\****************************************************************************/

ControlP5 cp5;
Arduino arduino;
MidiOutput midiOut;
PFont font;
int midiOutIndex = 0;
static final int[] minor = {0,2,3,5,7,8,10};
Average ranger1, ranger2, laser1, laser2;
boolean b1Playing, b2Playing;
int b1LastNote, b2LastNote;

void setup() {
  size(640,480,P2D);
  smooth();
  frameRate(360);
  textMode(SCREEN);
  font = createFont("Arial", 14, true);
  textFont(font);
  setupArduino();
  setupMidi();
  ranger1 = new Average(80);
  ranger2 = new Average(80);
  laser1 = new Average(10);
  laser2 = new Average(10);
  arduino.pinMode(6,Arduino.INPUT);
  arduino.pinMode(7,Arduino.INPUT);
  
  b1Playing = false;
  b2Playing = false;
  b1LastNote = 0;
  b2LastNote = 0;
}
void draw() {
  background(0);
  // update
  ranger1.push(arduino.analogRead(0));
  ranger2.push(arduino.analogRead(1));
  laser1.push(arduino.digitalRead(6));
  laser2.push(arduino.digitalRead(7));
  
  // display
  text("RANGER1: " + ranger1.medianCm(),20,30);
  text("RANGER2: " + ranger2.medianCm(),20,45);
  text("LASER1: " + laser1.medianBool().toString(),20,60);
  text("LASER2: " + laser2.medianBool().toString(),20,75);
  text("FPS: " + frameRate,20,90);
  
  if (laser1.medianBool() == false) {
    if (b1Playing == false) {
      int c = 5;
      
      while (c > 0) {
        ranger1.push(arduino.analogRead(0));
        c--;
      }
      b1LastNote = constrain( (48+minor[constrain((int)(ranger1.medianCm()/5),0,minor.length-1)]), 0, 127);
      midiOut.sendNoteOn(0,b1LastNote,90);
      b1Playing = true;
    }
  }
  if (laser1.medianBool() == true) {
    if (b1Playing == true) {
      midiOut.sendNoteOff(0,b1LastNote,90);
      b1Playing = false;
    }
  }
  if (laser2.medianBool() == false) {
    if (b2Playing == false) {
      int c = 5;
      
      while (c > 0) {
        ranger2.push(arduino.analogRead(1));
        c--;
      }
      b2LastNote = constrain( (60+minor[constrain((int)(ranger2.medianCm()/5),0,minor.length-1)]), 0, 127);
      midiOut.sendNoteOn(1,b2LastNote,90);
      b2Playing = true;
    }
  }
  if (laser2.medianBool() == true) {
    if (b2Playing == true) {
      midiOut.sendNoteOff(1,b2LastNote,90);
      b2Playing = false;
    }
  }
}
class Average {
  float[] raw;
  int index;
  int length;
  
  Average(int l) {
    length = l;
    raw = new float[length];
    index = 0;
  }
  void push(float f) {
    raw[index] = f;
    index ++;
    if (index >= length) {
      index = 0;
    }
  }
  float mean() {
    float sum = 0;
    for (int i=0; i < length; i++) {
      sum += raw[i];
    }
    return sum/(float)length;
  }
  float median() {
    float[] p = raw;
    Arrays.sort(p);
    return p[(int)(length/2)];
  }
  float medianCm() {
    float[] p = raw;
    Arrays.sort(p);
    return 12343.85*pow( p[(int)(length/2)],-1.15);
  }
  Boolean medianBool() {
    float[] p = raw;
    Arrays.sort(p);
    if (p[(int)(length/2)] > .5) {
      return new Boolean(true);
    }
    else {
      return new Boolean(false);
    }
  }
      
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

@Override
void exit() {
  midiOut.closeMidi();
  super.stop();
  System.exit(0);
}

