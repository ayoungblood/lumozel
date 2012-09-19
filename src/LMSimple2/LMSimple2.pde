import oscP5.*;
import netP5.*;
import cc.arduino.*;
import processing.serial.*;
import controlP5.*;
import rwmidi.*;

/****************************************************************************\
 * Simple Lumozel Interface for Two-Beam use
 * This sketch provides basic functionality for two beams, basic parameters
 * only, and only basic OSC control
 * Also, using plaintext file text logging
 * 
 * License: TODO: Find license
 * Author: Akira Youngblood
\****************************************************************************/

ControlP5 cp5;
Arduino arduino;
MidiOutput midiOut;
PFont font;
PrintWriter logfile;
OscP5 oscP5;
NetAddress client;
int beam1X = 10, beam1Y = 10;
int beam2X = 290, beam2Y = 10;
DropdownList beam1NoteList;

void setup() {
  size(640,480,P2D);
  smooth();
  frameRate(480);
  smooth();
  textMode(SCREEN);
  font = createFont("Arial", 18, true);
  textFont(font);
  setupArduino(0);
  setupMidi(3);
  setupOsc(8000,"10.0.1.25",9000);
  setupGUI();
  //logfile = createWriter("log.txt");
  //logfile.print("Started at " + (int)(System.currentTimeMillis()/1000L) + "\n\n");
}
void draw() {
  background(0);
  drawGUI();
  cp5.draw(); // ControlP5.draw must be called explicitly when using hte P2D renderer
}

class LMS2Beam {
  int base;
  int[] scale;
  MidiOutput out;
  int midiChannel;
  int velocity;
  
  LMS2Beam(MidiOutput mo) {
    base = 60;
    int[] scale = LMConstants.Scales.major;
    out = mo;
    midiChannel = 0;
    velocity = 90;
  }
  
  void noteOnFromIndex(int index) {
    if (index >= 0 && index < scale.length) {
      out.sendNoteOn(midiChannel,base+scale[index],velocity);
    }
  }
  void noteOffFromIndex(int index) {
    if (index >= 0 && index < scale.length) {
      out.sendNoteOff(midiChannel,base+scale[index],velocity);
    }
  }
  // Using mutators and accessors, but skipping most of the accessors for now
  void setBase(int b) {
    base = b;
  }
  void setScale(int[] s) {
    scale = s;
  }
  void octaveDn() {
    base -= 12;
  }
  void octaveUp() {
    base += 12;
  }
  
}
  
static class LMConstants {
  static final String[] midiOffsets = {"C","C#","D","D#","E","F","F#","G","A","A#","B"};
  static final String[] scaleNames = {"major","minor","chromatic","pentatonic"};
  static class Scales {
    static final int[] major = {0,2,4,5,7,9,11};
    static final int[] minor = {0,2,3,5,7,8,10};
    static final int[] chromatic = {0,1,2,3,4,5,6,7,8,9,10,11};
    static final int[] pentatonic = {0,2,4,7,9};
  }
}
void drawGUI() {
  textAlign(TOP,LEFT);
  text("BEAM 1", beam1X, beam1Y+13);
  stroke(255);
  line(beam1X,beam1Y+18,beam1X+270,beam1Y+18);
  text("BEAM 2", beam2X, beam2Y+13);
  stroke(255);
  line(beam2X,beam2Y+18,beam2X+270,beam2Y+18);
}
void setupGUI() {
  cp5 = new ControlP5(this);
  // beam1
  cp5.addButton("1 OCTV DN")
  .setSize(60,20)
  .setPosition(beam1X,beam1Y+25)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
  ;
  cp5.addButton("1 OCTV UP")
  .setSize(60,20)
  .setPosition(beam1X+70,beam1Y+25)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
  ;
  cp5.addTextlabel("1 NOTE SEL LBL")
  .setSize(60,20)
  .setPosition(beam1X+140,beam1Y+37)
  .setText("1 NOTE SEL")
  ;
  beam1NoteList = cp5.addDropdownList("1 NOTE SEL")
  .setSize(60,100)
  .setPosition(beam1X+140,beam1Y+35)
  .addItems(LMConstants.midiOffsets)
  .addListener(new ControlListener() {
    public void controlEvent(ControlEvent theEvent) {
      println((int)theEvent.getValue());
      // TODO
    }
  })
  .setIndex(0)
  .bringToFront()
  ;
  cp5.addTextlabel("1 SCALE SEL LBL")
  .setSize(60,20)
  .setPosition(beam1X+210,beam1Y+37)
  .setText("1 SCALE SEL")
  ;
  cp5.addDropdownList("1 SCALE SEL")
  .setSize(60,100)
  .setPosition(beam1X+210,beam1Y+35)
  .addItems(LMConstants.scaleNames)
  .addListener(new ControlListener() {
    public void controlEvent(ControlEvent theEvent) {
      println((int)theEvent.getValue());
      // TODO
    }
  })
  .setIndex(0)
  .bringToFront()
  ;
  // beam2
  cp5.addButton("2 OCTV DN")
  .setSize(60,20)
  .setPosition(beam2X,beam2Y+25)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
  ;
  cp5.addButton("2 OCTV UP")
  .setSize(60,20)
  .setPosition(beam2X+70,beam2Y+25)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
  ;
  cp5.addTextlabel("2 NOTE SEL LBL")
  .setSize(60,20)
  .setPosition(beam2X+140,beam2Y+37)
  .setText("2 NOTE SEL")
  ;
  beam1NoteList = cp5.addDropdownList("2 NOTE SEL")
  .setSize(60,100)
  .setPosition(beam2X+140,beam2Y+35)
  .addItems(LMConstants.midiOffsets)
  .addListener(new ControlListener() {
    public void controlEvent(ControlEvent theEvent) {
      println((int)theEvent.getValue());
      // TODO
    }
  })
  .setIndex(0)
  .bringToFront()
  ;
  cp5.addTextlabel("2 SCALE SEL LBL")
  .setSize(60,20)
  .setPosition(beam2X+210,beam2Y+37)
  .setText("2 SCALE SEL")
  ;
  cp5.addDropdownList("2 SCALE SEL")
  .setSize(60,100)
  .setPosition(beam2X+210,beam2Y+35)
  .addItems(LMConstants.scaleNames)
  .addListener(new ControlListener() {
    public void controlEvent(ControlEvent theEvent) {
      println((int)theEvent.getValue());
      // TODO
    }
  })
  .setIndex(0)
  .bringToFront()
  ;
  println(millis() + ": CP5 setup");
}
// Incoming OSC event callback
void oscEvent(OscMessage in) {
  if (in.typetag().equals("f")) {
    
  }
  else {
    println(millis() + ": discarded OSC message with typetag " + in.typetag());
  }
}
void setupArduino(int j) {
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[j], 57600);
  println("Using Arduino at: " + Arduino.list()[j]);
}
void setupMidi(int j) {
  println(RWMidi.getOutputDevices());
  midiOut = RWMidi.getOutputDevices()[j].createOutput();
  println("Using "+RWMidi.getOutputDevices()[j]+" for MIDI output");
}
void setupOsc(int serverPort, String clientIP, int clientPort) {
  oscP5 = new OscP5(this,serverPort);
  client = new NetAddress(clientIP,clientPort);
  println(millis() + ": OSC Started");
}
void midiPanic() {
  for (int ch=0; ch<15; ch++) {
    midiOut.sendController(0xB+ch, 0x7B, 0x00);
  }
}

@Override
void exit() {
  midiOut.closeMidi();
  //logfile.flush();
  //logfile.close();
  super.stop();
  System.exit(0);
}

