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
PFont font, smallFont;
PrintWriter logfile;
OscP5 oscP5;
NetAddress client;
final int beam1X = 10, beam1Y = 10;
final int beam2X = 290, beam2Y = 10;
final int systemX = 10, systemY = 100;
final int midiX = 290, midiY = 100;
final int oscX = 10, oscY = 200;
DropdownList beam1NoteList;
LMS2Beam beam1, beam2;

void setup() {
  size(640,480,P2D);
  smooth();
  frameRate(480);
  smooth();
  textMode(SCREEN);
  font = createFont("Arial", 18, true);
  smallFont = createFont("Arial", 12, true);
  textFont(font);
  setupArduino(0);
  setupMidi(3);
  setupOsc(8000,"10.0.1.25",9000);
  setupGUI();
  //logfile = createWriter("log.txt");
  //logfile.print("Started at " + (int)(System.currentTimeMillis()/1000L) + "\n\n");
  
  beam1 = new LMS2Beam(midiOut);
  beam2 = new LMS2Beam(midiOut);
}
void draw() {
  background(0);
  drawGUI();
  cp5.draw(); // ControlP5.draw must be called explicitly when using the P2D renderer
}

class LMS2Beam {
  int base;
  int[] scale;
  MidiOutput out;
  int midiChannel;
  int velocity;
  
  LMS2Beam(MidiOutput mo) {
    base = 60;
    scale = LMConstants.Scales.Major.offsets;
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
  String getInfo() {
    return "SCL: " + LMConstants.midiOffsets[base%12] + " OCTV: " + floor(base/12);
  }
  String getRawInfo() {
    return "BASE: " + base;
  }
  void setBase(int b) {
    if (b >= 0 && b <= 127) {
      base = b;
    }
    else {
      // TODO: should throw exception here, perhaps OutOfRangeish
      println("invalid value, ignored");
    }
  }
  int getBase() {
    return base;
  }
  void setScale(int[] s) {
    scale = s;
  }
  void octaveDn() {
    if (base >= 12) {
      base -= 12;
    }
    else {
      // TODO
    }
  }
  void octaveUp() {
    if (base <= 115) {
      base += 12;
    }
    else {
      // TODO
    }
  }
}
  
static class LMConstants {
  static final String[] midiOffsets = {"C","C#","D","D#","E","F","F#","G","A","A#","B"};
  static final String[] scaleNames = {"major","minor","chromatic","pentatonic"};
  static class Scales {
    static final class Major {
      String name = "major";
      static int[] offsets = {0,2,4,5,7,9,11};
    }
    static final class Minor {
      String name = "minor";
      static int[] offsets = {0,2,3,5,7,8,10};
    }
    static final class Chromatic {
      String name = "chromatic";
      static int[] offsets = {0,1,2,3,4,5,6,7,8,9,10,11};
    }
    static final class Pentatonic {
      String name = "pentatonic";
      static int[] offsets = {0,2,4,7,9};
    }
  }
  // TODO Scales class is still broken, Scales needs to be an array of Scale object, each iwth name and offsets
}
void drawGUI() {
  textFont(font);
  textAlign(TOP,LEFT);
  text("BEAM 1", beam1X, beam1Y+13);
  stroke(255);
  line(beam1X,beam1Y+18,beam1X+270,beam1Y+18);
  textFont(smallFont);
  text(beam1.getInfo(),beam1X,beam1Y+60);
  text(beam1.getRawInfo(),beam1X,beam1Y+75);
  textFont(font);
  text("BEAM 2", beam2X, beam2Y+13);
  stroke(255);
  line(beam2X,beam2Y+18,beam2X+270,beam2Y+18);
  text("SYSTEM", systemX, systemY+13);
  line(systemX,systemY+18,systemX+270,systemY+18);
  textFont(smallFont);
  int sysLineOffset = 34;
  text("mX",systemX,systemY+sysLineOffset);
  float lineH = textAscent()+textDescent();
  text("mY",systemX,systemY+sysLineOffset+lineH);
  text("FPS",systemX,systemY+sysLineOffset+2*lineH);
  text("LOCAL T",systemX,systemY+sysLineOffset+3*lineH);
  textAlign(TOP,RIGHT);
  text(mouseX,systemX+100,systemY+sysLineOffset);
  text(mouseY,systemX+100,systemY+sysLineOffset+lineH);
  text(nf(frameRate,0,2),systemX+100,systemY+sysLineOffset+2*lineH);
  text(hour() + ":" + nf(minute(),2,-1) + ":" + nf(second(),2,-1),systemX+100,systemY+sysLineOffset+3*lineH);
  textFont(font);
  textAlign(TOP,LEFT);
  text("MIDI",midiX,midiY+13);
  line(midiX,midiY+18,midiX+270,midiY+18);
  text("OSC",oscX,oscY+13);
  line(oscX,oscY+18,oscX+270,oscY+18);
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
          beam1.octaveDn();
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
          beam1.octaveUp();
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
      if ((int)theEvent.getValue() == 0) {beam1.setScale(LMConstants.Scales.Major.offsets);}
      if ((int)theEvent.getValue() == 1) {beam1.setScale(LMConstants.Scales.Minor.offsets);}
      if ((int)theEvent.getValue() == 2) {beam1.setScale(LMConstants.Scales.Chromatic.offsets);}
      if ((int)theEvent.getValue() == 3) {beam1.setScale(LMConstants.Scales.Pentatonic.offsets);}
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
          beam2.octaveDn();
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
          beam2.octaveUp();
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
      if ((int)theEvent.getValue() == 0) {beam2.setScale(LMConstants.Scales.Major.offsets);}
      if ((int)theEvent.getValue() == 1) {beam2.setScale(LMConstants.Scales.Minor.offsets);}
      if ((int)theEvent.getValue() == 2) {beam2.setScale(LMConstants.Scales.Chromatic.offsets);}
      if ((int)theEvent.getValue() == 3) {beam2.setScale(LMConstants.Scales.Pentatonic.offsets);}
    }
  })
  .setIndex(0)
  .bringToFront()
  ;
  cp5.addButton("panic")
  .setSize(60,20)
  .setPosition(midiX,midiY+25)
  .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          midiPanic();
        }
      }
    })
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
    midiOut.sendController(ch, 0x7B, 0x00);
  }
  println("MIDI: sent 0x7B on all channels, panic");
}

@Override
void exit() {
  midiOut.closeMidi();
  //logfile.flush();
  //logfile.close();
  super.stop();
  System.exit(0);
}

