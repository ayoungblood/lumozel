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
PFont bigFont, smallFont;
int midiOutIndex = 0;
static final int[] minor = {0,2,3,5,7,8,10};
Average ranger1, ranger2, laser1, laser2;
boolean b1Playing, b2Playing;
int b1LastNote, b2LastNote;
int beam1X = 10, beam1Y = 10, beam2X = 290, beam2Y = 10;
int sysX = 10, sysY = 200, touchX = 290, touchY = 200;

void setup() {
  size(640,480,P2D);
  smooth();
  frameRate(360);
  setupGui();
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
  // Update all values
  ranger1.push(arduino.analogRead(0));
  ranger2.push(arduino.analogRead(1));
  laser1.push(arduino.digitalRead(6));
  laser2.push(arduino.digitalRead(7));
  
  // Main note-gen loop
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
  
  updateGui();
  
  cp5.draw(); // ControlP5.draw() must be explicitly called when using the P2D renderer
}

class Beam {
  boolean notePlaying;
  int lastNote;
  int base;
  int distanceScaleFactor;
  
  Beam() {
    notePlaying = false;
    lastNote = 0;
    base = 48;
    distanceScaleFactor = 5;
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

void updateGui() {
  // BEAM 1
  textFont(bigFont);
  textAlign(TOP,LEFT);
  text("BEAM 1", beam1X, beam1Y+13);
  stroke(255);
  line(beam1X,beam1Y+18,beam1X+270,beam1Y+18);
  textFont(smallFont);
  text("RANGER1 MDCM: " + ranger1.medianCm(),beam1X,beam1Y+32);
  text("LASER1 TRIG: " + laser1.medianBool().toString().toUpperCase(),beam1X,beam1Y+46);
  text("PLACEHOLDER",beam1X,beam1Y+60);
  
  // BEAM 2
  textFont(bigFont);
  textAlign(TOP,LEFT);
  text("BEAM 2", beam2X, beam2Y+13);
  stroke(255);
  line(beam2X,beam2Y+18,beam2X+270,beam2Y+18);
  textFont(smallFont);
  text("RANGER2 MDCM: " + ranger2.medianCm(),beam2X,beam2Y+32);
  text("LASER2 TRIG: " + laser2.medianBool().toString().toUpperCase(),beam2X,beam2Y+46);
  text("PLACEHOLDER",beam2X,beam2Y+60);
  
  // SYSTEM
  textFont(bigFont);
  textAlign(TOP,LEFT);
  text("SYSTEM", sysX, sysY+13);
  stroke(255);
  line(sysX,sysY+18,sysX+270,sysY+18);
  textFont(smallFont);
  text("FPS: " + frameRate,sysX,sysY+32);
  
  // TOUCH
  textFont(bigFont);
  textAlign(TOP,LEFT);
  text("TOUCH", touchX, touchY+13);
  stroke(255);
  line(touchX,touchY+18,touchX+270,touchY+18);
  textFont(smallFont);
  text("PLACEHOLDER",touchX,touchY+32);
  
}

void setupGui() {
  textMode(SCREEN);
  bigFont = createFont("Arial", 18, true);
  smallFont = createFont("Arial", 12, true);
  cp5 = new ControlP5(this);
  cp5.addButton("1 OCTV DN")
  .setSize(60,20)
  .setPosition(beam1X,beam1Y+65)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // @Todo
          println("!! Error: Event handler empty");
        }
      }
    })
  ;
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


