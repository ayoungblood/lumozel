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
static final String[] scaleNames = {"major","minor","chromatic","pentatonic"};
static final int[] minor = {0,2,3,5,7,8,10};
static final int[] major = {0,2,4,5,7,9,11};
static final int[] chromatic = {0,1,2,3,4,5,6,7,8,9,10,11};
static final int[] pentatonic = {0,2,4,7,9};
static final String[] midiNoteNames = {"C","C#","D","D#","E","F","F#","G","G#","A","A#","B","C"};
int ranger1Pin = 0, ranger2Pin = 1, laser1Pin = 3, laser2Pin = 4;
Average ranger1, ranger2, laser1, laser2;
int beam1X = 10, beam1Y = 10, beam2X = 290, beam2Y = 10;
int sysX = 10, sysY = 180, touchX = 290, touchY = 180;
Beam beam1, beam2;
// TouchSensor ts1, ts2, ts3, ts4;

void setup() {
  size(570,270,P2D);
  smooth();
  frameRate(360);
  setupGui();
  setupArduino();
  setupMidi();
  ranger1 = new Average(80);
  ranger2 = new Average(80);
  laser1 = new Average(10);
  laser2 = new Average(10);
  arduino.pinMode(laser1Pin,Arduino.INPUT);
  arduino.pinMode(laser2Pin,Arduino.INPUT);
  
  beam1 = new Beam();
  beam2 = new Beam();
  //ts1 = new TouchSensor(arduino,6,0);
  //ts2 = new TouchSensor(arduino,7,1);
  //ts3 = new TouchSensor(arduino,10);
  //ts4 = new TouchSensor(arduino,11);
}
void draw() {
  background(0);
  // Update all values
  ranger1.push(arduino.analogRead(ranger1Pin));
  ranger2.push(arduino.analogRead(ranger2Pin));
  laser1.push(arduino.digitalRead(laser1Pin));
  laser2.push(arduino.digitalRead(laser2Pin));
  
  // Main note-gen loop
  if (laser1.medianBool() == false) {
    if (beam1.notePlaying == false) {
      int c = 5;
      
      while (c > 0) {
        ranger1.push(arduino.analogRead(ranger1Pin));
        c--;
      }
      beam1.lastNote = constrain( (beam1.base+beam1.scale[constrain((int)(ranger1.medianCm()/beam1.distanceScaleFactor),0,minor.length-1)]), 0, 127);
      midiOut.sendNoteOn(0,beam1.lastNote,90);
      beam1.notePlaying = true;
    }
  }
  if (laser1.medianBool() == true) {
    if (beam1.notePlaying == true) {
      midiOut.sendNoteOff(0,beam1.lastNote,90);
      beam1.notePlaying = false;
    }
  }
  // --------------------------------
  if (laser2.medianBool() == false) {
    if (beam2.notePlaying == false) {
      int c = 5;
      
      while (c > 0) {
        ranger2.push(arduino.analogRead(ranger2Pin));
        c--;
      }
      beam2.lastNote = constrain( (beam2.base+beam2.scale[constrain((int)(ranger2.medianCm()/beam2.distanceScaleFactor),0,minor.length-1)]), 0, 127);
      midiOut.sendNoteOn(0,beam2.lastNote,90);
      beam2.notePlaying = true;
    }
  }
  if (laser2.medianBool() == true) {
    if (beam2.notePlaying == true) {
      midiOut.sendNoteOff(0,beam2.lastNote,90);
      beam2.notePlaying = false;
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
  int[] scale;
  String scaleName;
  
  Beam() {
    notePlaying = false;
    lastNote = 0;
    base = 48;
    distanceScaleFactor = 5;
    scale = major;
    scaleName = "major";
  }
  void octaveDn() {
    if (base - 12 >= 0) {
      base-=12;
    }
  }
  void octaveUp() {
    if (base + 12 <= 127) {
      base+=12;
    }
  }
  void baseDn() {
    if (base >= 1) {
      base--;
    }
  }
  void baseUp() {
    if (base <= 126) {
      base++;
    }
  }
}

String midiToNoteName(int i) {
  return midiNoteNames[constrain(i,0,127)%12];
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
  textAlign(LEFT,TOP);
  text("BEAM 1", beam1X, beam1Y);
  textAlign(RIGHT,TOP);
  text(midiToNoteName(beam1.base) + " " + beam1.scaleName.toUpperCase(), beam1X+270, beam1Y);
  textAlign(LEFT,TOP);
  stroke(255);
  line(beam1X,beam1Y+18,beam1X+270,beam1Y+18);
  textFont(smallFont);
  text("R1 MDCM:",beam1X,beam1Y+24);
  text("L1 TRIG:",beam1X,beam1Y+40);
  text("NOTE OUT:",beam1X,beam1Y+56);
  text("BASE:",beam1X+140,beam1Y+24);
  text("MULT:",beam1X+140,beam1Y+40);
  text("RAW:",beam1X+140,beam1Y+56);
  textAlign(RIGHT,TOP);
  text(nf(ranger1.medianCm(),0,2),beam1X+130,beam1Y+24);
  text(laser1.medianBool().toString().toUpperCase(),beam1X+130,beam1Y+40);
  text(midiToNoteName(beam1.lastNote) + "/" + beam1.lastNote,beam1X+130,beam1Y+56);
  text(beam1.base + "/" + midiToNoteName(beam1.base),beam1X+270,beam1Y+24);
  text(beam1.distanceScaleFactor,beam1X+270,beam1Y+40);
  text(arduino.analogRead(ranger1Pin),beam1X+270,beam1Y+56);
  
  // BEAM 2
  textFont(bigFont);
  textAlign(LEFT,TOP);
  text("BEAM 2", beam2X, beam2Y);
  textAlign(RIGHT,TOP);
  text(midiToNoteName(beam2.base) + " " + beam2.scaleName.toUpperCase(), beam2X+270, beam2Y);
  textAlign(LEFT,TOP);
  stroke(255);
  line(beam2X,beam2Y+18,beam2X+270,beam2Y+18);
  textFont(smallFont);
  text("R2 MDCM:",beam2X,beam2Y+24);
  text("L2 TRIG:",beam2X,beam2Y+40);
  text("NOTE OUT:",beam2X,beam2Y+56);
  text("BASE:",beam2X+140,beam2Y+24);
  text("MULT:",beam2X+140,beam2Y+40);
  text("RAW:",beam2X+140,beam2Y+56);
  textAlign(RIGHT,TOP);
  text(nf(ranger2.medianCm(),0,2),beam2X+130,beam2Y+24);
  text(laser2.medianBool().toString().toUpperCase(),beam2X+130,beam2Y+40);
  text(midiToNoteName(beam2.lastNote) + "/" + beam2.lastNote,beam2X+130,beam2Y+56);
  text(beam2.base + "/" + midiToNoteName(beam2.base),beam2X+270,beam2Y+24);
  text(beam2.distanceScaleFactor,beam2X+270,beam2Y+40);
  text(arduino.analogRead(ranger2Pin),beam2X+270,beam2Y+56);
  
  // SYSTEM
  textFont(bigFont);
  textAlign(LEFT,TOP);
  text("SYSTEM", sysX, sysY);
  stroke(255);
  line(sysX,sysY+18,sysX+270,sysY+18);
  textFont(smallFont);
  text("FPS:",sysX,sysY+24);
  text("MX x MY:",sysX,sysY+40);
  textAlign(RIGHT,TOP);
  text(frameRate,sysX+130,sysY+24);
  text(mouseX + " x " + mouseY,sysX+130,sysY+40);
  
  // TOUCH
  textFont(bigFont);
  textAlign(LEFT,TOP);
  text("TOUCH", touchX, touchY);
  stroke(255);
  line(touchX,touchY+18,touchX+270,touchY+18);
  textFont(smallFont);
  text("DISABLED",touchX,touchY+24);
  
}

void setupGui() {
  textMode(SCREEN);
  bigFont = createFont("Arial", 18, true);
  smallFont = createFont("Arial", 12, true);
  cp5 = new ControlP5(this);
  // BEAM 1
  cp5.addButton("1 OCTV DN")
  .setSize(60,20)
  .setPosition(beam1X,beam1Y+75)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          beam1.octaveDn();
        }
      }
    })
  ;
  cp5.addButton("1 OCTV UP")
  .setSize(60,20)
  .setPosition(beam1X+70,beam1Y+75)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          beam1.octaveUp();
        }
      }
    })
  ;
  cp5.addButton("1 BASE DN")
  .setSize(60,20)
  .setPosition(beam1X+140,beam1Y+75)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          beam1.baseDn();
        }
      }
    })
  ;
  cp5.addButton("1 BASE UP")
  .setSize(60,20)
  .setPosition(beam1X+210,beam1Y+75)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          beam1.baseUp();
        }
      }
    })
  ;
  
  cp5.addDropdownList("scale B1")
    .setPosition(beam1X,beam1Y+115)
    .setSize(60,100)
    .addListener(new ControlListener() {
      public void controlEvent(ControlEvent theEvent) {
        switch((int)theEvent.getValue()) {
          case 0:
            beam1.scale = major;
            beam1.scaleName = "major";
            break;
          case 1:
            beam1.scale = minor;
            beam1.scaleName = "minor";
            break;
          case 2:
            beam1.scale = chromatic;
            beam1.scaleName = "chromatic";
            break;
          default:
            beam1.scale = pentatonic;
            beam1.scaleName = "pentatonic";
            break;
        }
      }
    })
    .addItems(scaleNames)
    ;
  cp5.addButton("1 DFSC DN")
  .setSize(60,20)
  .setPosition(beam1X+140,beam1Y+105)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          if (beam1.distanceScaleFactor >= 2) {
            beam1.distanceScaleFactor--;
          }
        }
      }
    })
  ;
  cp5.addButton("1 DFSC UP")
  .setSize(60,20)
  .setPosition(beam1X+210,beam1Y+105)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          if (beam1.distanceScaleFactor <= 15) {
            beam1.distanceScaleFactor++;
          }
        }
      }
    })
  ;
  // BEAM 2
  cp5.addButton("2 OCTV DN")
  .setSize(60,20)
  .setPosition(beam2X,beam2Y+75)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          beam2.octaveDn();
        }
      }
    })
  ;
  cp5.addButton("2 OCTV UP")
  .setSize(60,20)
  .setPosition(beam2X+70,beam2Y+75)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          beam2.octaveUp();
        }
      }
    })
  ;
  cp5.addButton("2 BASE DN")
  .setSize(60,20)
  .setPosition(beam2X+140,beam2Y+75)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          beam2.baseDn();
        }
      }
    })
  ;
  cp5.addButton("2 BASE UP")
  .setSize(60,20)
  .setPosition(beam2X+210,beam2Y+75)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          beam2.baseUp();
        }
      }
    })
  ;
  cp5.addDropdownList("scale B2")
    .setPosition(beam2X,beam2Y+115)
    .setSize(60,100)
    .addListener(new ControlListener() {
      public void controlEvent(ControlEvent theEvent) {
        switch((int)theEvent.getValue()) {
          case 0:
            beam2.scale = major;
            beam2.scaleName = "major";
            break;
          case 1:
            beam2.scale = minor;
            beam2.scaleName = "minor";
            break;
          case 2:
            beam2.scale = chromatic;
            beam2.scaleName = "chromatic";
            break;
          default:
            beam2.scale = pentatonic;
            beam2.scaleName = "pentatonic";
            break;
        }
      }
    })
    .addItems(scaleNames)
    ;
  cp5.addButton("2 DFSC DN")
  .setSize(60,20)
  .setPosition(beam2X+140,beam2Y+105)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          if (beam2.distanceScaleFactor >= 2) {
            beam2.distanceScaleFactor--;
          }
        }
      }
    })
  ;
  cp5.addButton("2 DFSC UP")
  .setSize(60,20)
  .setPosition(beam2X+210,beam2Y+105)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          if (beam2.distanceScaleFactor <= 15) {
            beam2.distanceScaleFactor++;
          }
        }
      }
    })
  ;
  // SYSTEM
  cp5.addButton("PANIC")
  .setSize(60,20)
  .setPosition(sysX,sysY+60)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          panicMidi();
        }
      }
    })
  ;
  cp5.addButton("DEBUG")
  .setSize(60,20)
  .setPosition(sysX+70,sysY+60)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          println("Unimplemented event handler!");
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
      for (int vl=0;vl<128;vl++) {
        midiOut.sendNoteOff(ch,nt,63);
      }
    }
  }
  println("MIDI panic sent");
}

@Override
void exit() {
  midiOut.closeMidi();
  super.stop();
  System.exit(0);
}

/* @Todo fix touch sensor stuff
class TouchSensor {
  int pin;
  long startTime;
  long nextTime;
  long counter;
  Arduino ar;
  int actionID;
  
  TSThread heart;
  TouchSensor(Arduino a, int p, int aid) {
    ar = a;
    pin = p;
    startTime = 0;
    nextTime = 0;
    counter = 0;
    heart = new TSThread();
    heart.start();
    actionID = aid;
  }
  
  class TSThread extends Thread {
    boolean running;
    String id;
    TSThread() {
      id = java.lang.Integer.toHexString((int)random(0xffffff));
      println("TSThread " + id + " constructed");
    }
    @Override
    void start() {
      running = true;
      super.start();
      println("TSThread " + id + " started");
    }
    @Override
    void run() {
      while (running) {
        counter = 0;
        ar.pinMode(pin, Arduino.OUTPUT);
        ar.digitalWrite(pin, Arduino.HIGH);
        delay(1);
        ar.digitalWrite(pin, Arduino.LOW);
        ar.pinMode(pin, Arduino.INPUT);
        delay(1);
        while (ar.digitalRead(pin) == Arduino.HIGH) {
          counter ++;
          println(counter);
          delay(1);
          if (counter > 5) {
            println("TSThread " + id + " event handler fired with count of " + counter);
            
            switch(actionID) {
              case 0:
                println("Action 0");
                break;
              case 1:
                println("Action 1");
                break;
            }
            
            delay(1000);
            break;
          }
        }
      }
      println("TSThread " + id + " exited with unknown status!");
    }
    void quit() {
      running = false;
      interrupt();
    }
  }
}
*/

