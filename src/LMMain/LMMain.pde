import cc.arduino.*;
import processing.serial.*;
import controlP5.*;
import rwmidi.*;
import oscP5.*;
import netP5.*;

/****************************************************************************\
 * Main Lumozel Software Interface
 * 
 * 
 * 
 * License: TODO: Find license
 * Author: Akira Youngblood
\****************************************************************************/

ControlP5 cp5;
PFont mainFont, smallFont;
Arduino arduino;
static final int ARDUINO_INDEX = 0; // This is index of Serial.list() which matches the Arduino, typically /dev/tty.usbserial-*

// MIDI
LMMidiControl midiSystem;
int midiX = 10, midiY = 160; // This makes moving around the entire MIDI GUI section much easier
DropdownList midiInputList, midiOutputList, ptChList;

// OSC
int oscX = 400, oscY = 160; // Facilitates moving the GUI lump around

// SYS
LMDisplayList systemStatusLog;

// Beam 1
DropdownList b1BaseNote, b1Scale, b1Mod, b1MidiChannel, b1Presets;
Numberbox b1DivisionsBox;
int b1Divisions;
LMDisplayDivs beam1Divs;
LMDisplayBar beam1RawBar, beam1FiltBar;

// Beam 2
DropdownList b2BaseNote, b2Scale, b2Mod, b2MidiChannel, b2Presets;
Numberbox b2DivisionsBox;
int b2Divisions;
LMDisplayDivs beam2Divs;
LMDisplayBar beam2RawBar, beam2FiltBar;

void setup() {
  size(1024,768,P2D); // Using the P2D renderer because it is fast. Fast renderer = better response. TODO: resize window
  smooth();
  frameRate(480);
  
  createGUI();
  
  // setupArduino();
  
  midiSystem = new LMMidiControl(2, 3);

}

void draw() {
  background(0);
  updateGUI();

  cp5.draw(); // Necessary because of the P2D renderer
}

// Overriding the P5 exit method, because we need to shut down all modules properly.
void exit() {
  println( millis() + ": Exiting...");
  midiSystem.stop();
  // System
  super.stop();
  System.exit(0); // This is needed because it destroys the window. super.stop() does not destroy the window
}

// GUI creation, ControlP5 initialization, and font setup
void createGUI() {
  cp5 = new ControlP5(this);
  // TODO: setup LMDisplayLists for history thingies
  
  // Font setup. Two fonts are created
  mainFont = createFont("SansSerif", 16);
  smallFont = createFont("SansSerif", 12);
  textMode(SCREEN); // This is necessary because we are using the P2D renderer
  textAlign(LEFT, TOP);
  
  // Main system
  systemStatusLog = new LMDisplayList(10,600);
  
  
  // Beam 1 ----------------------------------------------------------------------***********************
  cp5.addButton("enable B1")
    .setPosition(10,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("disable B1")
    .setPosition(75,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("status B1")
    .setPosition(140,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("panic B1")
    .setPosition(205,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("- octv B1")
    .setPosition(270,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("+ octv B1")
    .setPosition(335,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  b1BaseNote = cp5.addDropdownList("base B1")
    .setPosition(10,70)
    .setSize(60,170)
    ;
  for (int i=0; i < LMConstants.midiOffsets.length; i++) {
    b1BaseNote.addItem(LMConstants.midiOffsets[i], i);
  }
  b1Scale = cp5.addDropdownList("scale B1")
    .setPosition(75,70)
    .setSize(60,100)
    ;
  b1Scale.addItem("MAJOR", 0);
  b1Scale.addItem("MINOR", 1);
  b1Scale.addItem("CHROMATIC", 2);
  b1Scale.addItem("PENTATONIC", 3);
  b1Mod = cp5.addDropdownList("mod B1")
    .setPosition(140,70)
    .setSize(60,100)
    ;
  b1Mod.addItem("PORTA OFF", 0);
  b1Mod.addItem("PORTA ON", 1);
  b1MidiChannel = cp5.addDropdownList("channel B1")
    .setPosition(205,70)
    .setSize(60,120)
    ;
  for (int i=1; i <= 16; i++) {
    b1MidiChannel.addItem("CH " + i, i);
  }
  b1Presets = cp5.addDropdownList("presets B1")
    .setPosition(270,70)
    .setSize(125,100)
    ;
  b1Presets.addItem("C MAJ BASIC", 0);
  b1Presets.addItem("C MIN BASIC", 1);
  b1Presets.addItem("G PENT SPLIT", 2);
  b1Presets.addItem("CHROMATIC NORMAL", 3);
  b1DivisionsBox = cp5.addNumberbox("b1Divisions")
    .setPosition(10,101)
    .setSize(29,18)
    .setValue(7)
    .setMin(1)
    .setMax(23)
    .setMultiplier(0.0625)
    .setCaptionLabel("")
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED || theEvent.getAction() == ControlP5.ACTION_RELEASEDOUTSIDE) {
          beam1Divs.setDivs((int)b1DivisionsBox.getValue());
          // Update beam controller divisions here
        }
      }
    })
    ;
  cp5.addTextlabel("b1DivsLabel")
    .setPosition(42,102)
    .setValue("DIVS")
    ;
  beam1Divs = new LMDisplayDivs(10,122);
  beam1RawBar = new LMDisplayBar(10,131);
  beam1FiltBar = new LMDisplayBar(10, 141);
  
  // Beam 2 ----------------------------------------------------------------------***********************
  cp5.addButton("enable B2")
    .setPosition(400,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("disable B2")
    .setPosition(465,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("status B2")
    .setPosition(530,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("panic B2")
    .setPosition(595,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("- octv B2")
    .setPosition(660,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  cp5.addButton("+ octv B2")
    .setPosition(725,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          // TODO
        }
      }
    })
    ;
  b2BaseNote = cp5.addDropdownList("base B2")
    .setPosition(400,70)
    .setSize(60,170)
    ;
  for (int i=0; i < LMConstants.midiOffsets.length; i++) {
    b2BaseNote.addItem(LMConstants.midiOffsets[i], i);
  }
  b2Scale = cp5.addDropdownList("scale B2")
    .setPosition(465,70)
    .setSize(60,100)
    ;
  b2Scale.addItem("MAJOR", 0);
  b2Scale.addItem("MINOR", 1);
  b2Scale.addItem("CHROMATIC", 2);
  b2Scale.addItem("PENTATONIC", 3);
  b2Mod = cp5.addDropdownList("mod B2")
    .setPosition(530,70)
    .setSize(60,100)
    ;
  b2Mod.addItem("PORTA OFF", 0);
  b2Mod.addItem("PORTA ON", 1);
  b2MidiChannel = cp5.addDropdownList("channel B2")
    .setPosition(595,70)
    .setSize(60,120)
    ;
  for (int i=1; i <= 16; i++) {
    b2MidiChannel.addItem("CH " + i, i);
  }
  b2Presets = cp5.addDropdownList("presets B2")
    .setPosition(660,70)
    .setSize(125,100)
    ;
  b2Presets.addItem("C MAJ BASIC", 0);
  b2Presets.addItem("C MIN BASIC", 1);
  b2Presets.addItem("G PENT SPLIT", 2);
  b2Presets.addItem("CHROMATIC NORMAL", 3);
  b2DivisionsBox = cp5.addNumberbox("b2Divisions")
    .setPosition(400,101)
    .setSize(29,18)
    .setValue(7)
    .setMin(1)
    .setMax(23)
    .setMultiplier(0.0625)
    .setCaptionLabel("")
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED || theEvent.getAction() == ControlP5.ACTION_RELEASEDOUTSIDE) {
          beam2Divs.setDivs((int)b2DivisionsBox.getValue());
          // TODO: Update beam controller divisions here
        }
      }
    })
    ;
  cp5.addTextlabel("b2DivsLabel")
    .setPosition(432,102)
    .setValue("DIVS")
    ;
  beam2Divs = new LMDisplayDivs(400,122);
  beam2RawBar = new LMDisplayBar(400,131);
  beam2FiltBar = new LMDisplayBar(400, 141);
  
  
  // MIDI ----------------------------------------------------------------------***********************
  cp5.addButton("start MIDI")
    .setPosition(midiX,midiY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          midiSystem.start();
        }
      }
    })
    ;
  cp5.addButton("stop MIDI")
    .setPosition(midiX+65,midiY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          midiSystem.stop();
        }
      }
    })
    ;
  cp5.addButton("panic MIDI")
    .setPosition(midiX+130,midiY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          midiSystem.panic();
        }
      }
    })
    ;
  cp5.addButton("list MIDI")
    .setPosition(midiX+195,midiY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          midiSystem.list();
        }
      }
    })
    ;
  cp5.addButton("test MIDI")
    .setPosition(midiX+260,midiY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_PRESSED) {
          midiSystem.sendTestNoteOn();
        }
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          midiSystem.sendTestNoteOff();
        }
      }
    })
    ;
  cp5.addButton("status MIDI")
    .setPosition(midiX+325,midiY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
    ;
  midiInputList = cp5.addDropdownList("MIDI INPUT DEVICE")
    .setPosition(midiX, midiY+60)
    .setSize(125,100)
    .addListener(new ControlListener() {
      public void controlEvent(ControlEvent theEvent) {
        println((int)theEvent.getValue());
        // TODO: update midiSystem.input here
      }
    })
    ;
  for (int i=0; i < RWMidi.getInputDevices().length; i++) {
    String s = i+" "+RWMidi.getInputDevices()[i].toString();
    if (s.length() > 24) {s = s.substring(0,24);}
    midiInputList.addItem(s, i);
  }
  // TODO: set value of input list, via init value of midiSystem
  midiOutputList = cp5.addDropdownList("MIDI OUTPUT DEVICE")
    .setPosition(midiX+130, midiY+60)
    .setSize(125,100)
    .addListener(new ControlListener() {
      public void controlEvent(ControlEvent theEvent) {
        println((int)theEvent.getValue());
        // TODO: update midiSystem.output here
      }
    })
    ;
  for (int i=0; i < RWMidi.getOutputDevices().length; i++) {
    String s = i+" "+RWMidi.getOutputDevices()[i].toString();
    if (s.length() > 24) {s = s.substring(0,24);}
    midiOutputList.addItem(s, i);
  }
  // TODO: set value of output list, via init value of midiSystem
  ptChList = cp5.addDropdownList("ECHO CH")
    .setPosition(midiX+325, midiY+60)
    .setSize(60,100)
    .addListener(new ControlListener() {
      public void controlEvent(ControlEvent theEvent) {
        println((int)theEvent.getValue());
        // TODO: update midiSystem.setPassthroughChannel here
      }
    })
    ;
  for (int i=1; i < 17; i ++) {
    ptChList.addItem("CH " + i, i);
  }
  // OSC ----------------------------------------------------------------------***********************
  cp5.addButton("start OSC")
    .setPosition(oscX,oscY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
    ;
  cp5.addButton("stop OSC")
    .setPosition(oscX+65,oscY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
    ;
  cp5.addButton("flush OSC")
    .setPosition(oscX+130,oscY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
    ;
  cp5.addButton("status OSC")
    .setPosition(oscX+195,oscY+25)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
    ;
  cp5.addTextfield("server IP")
    .setPosition(oscX+1, oscY+50)
    .setSize(83,18)
    ;
  cp5.addTextfield("server port")
    .setPosition(oscX+90, oscY+50)
    .setSize(55,18)
    ;
  cp5.addButton("set server port")
    .setCaptionLabel("<< set")
    .setPosition(oscX+150, oscY+50)
    .setSize(40,18)
    ;
  cp5.addTextfield("client 1 IP")
    .setPosition(oscX+1, oscY+85)
    .setSize(83,18)
    ;
  cp5.addTextfield("client 1 port")
    .setPosition(oscX+90, oscY+85)
    .setSize(55,18)
    ;
  cp5.addButton("set client 1")
    .setCaptionLabel("<< set")
    .setPosition(oscX+150, oscY+85)
    .setSize(40,18)
    ;
  cp5.addTextfield("client 2 IP")
    .setPosition(oscX+1, oscY+120)
    .setSize(83,18)
    ;
  cp5.addTextfield("client 2 port")
    .setPosition(oscX+90, oscY+120)
    .setSize(55,18)
    ;
  cp5.addButton("set client 2")
    .setCaptionLabel("<< set")
    .setPosition(oscX+150, oscY+120)
    .setSize(40,18)
    ;
  
}
// For redrawing anything that needs to be redrawn
void updateGUI() {
  strokeWeight(1);
  
  // Status log, should be moved lower
  systemStatusLog.draw();
  
  // Beam 1
  fill(255);
  textFont(mainFont);
  text("BEAM 1 >> HALTED", 10, 10); // This needs to take its string from a beam controller
  stroke(255);
  line(10,29,395,29);
  // below 2 lines are clumsy
  fill(2,52,77); noStroke();
  rect(10,75,385,20);
  fill(255);
  textFont(smallFont);
  text("KEY: C# MAJOR  OCTV: 4  BASE NOTE: 60  CHAN: 12",14,79); // This needs to take its string from a beam controller
  stroke(4,104,154);
  line(53,112,53,122);
  //line(10,122,395,122);
  
  beam1Divs.draw();
  // beam1RawBar.setValue(foo.raw);
  beam1RawBar.draw();
  // beam1FiltBar.setValue(foo.filt);
  beam1FiltBar.draw();
  
  // Beam 2
  fill(255);
  textFont(mainFont);
  text("BEAM 2 >> HALTED", 400, 10);
  stroke(255);
  line(400,29,785,29);
  // below 2 lines are clumsy
  fill(2,52,77); noStroke();
  rect(400,75,385,20);
  fill(255);
  textFont(smallFont);
  text("KEY: C# MAJOR  OCTV: 4  BASE NOTE: 60  CHAN: 12",414,79); // This needs to take its string from a beam controller
  stroke(4,104,154);
  line(443,112,443,122);
  beam2Divs.draw();
  // beam1RawBar.setValue(foo.raw);
  beam2RawBar.draw();
  // beam1FiltBar.setValue(foo.filt);
  beam2FiltBar.draw();
  
  // System stats
  fill(255);
  textFont(mainFont);
  text("CORE STATUS", 800, 10);
  stroke(255);
  line(800,29,1000,29);
  textFont(smallFont);
  float lineHeight = textAscent() + textDescent();
  text("UPDATE RT (FPS)", 800, 35);
  text("MOUSE X", 800, 35 + lineHeight);
  text("MOUSE Y", 800, 35 + lineHeight*2);
  text("FRAMES", 800, 35 + lineHeight*3);
  text("HAS FOCUS", 800, 35 + lineHeight*4);
  text("LOCAL TIME", 800, 35 + lineHeight*5);
  textAlign(RIGHT,TOP);
  text(nf(frameRate,0,2), 1000, 35);
  text(mouseX, 1000, 35 + lineHeight);
  text(mouseY, 1000, 35 + lineHeight*2);
  text(frameCount, 1000, 35 + lineHeight*3);
  text(new Boolean(focused).toString().toUpperCase(), 1000, 35 + lineHeight*4);
  text(hour() + ":" + nf(minute(),2,-1) + ":" + nf(second(),2,-1), 1000, 35 + lineHeight*5);
  textAlign(LEFT,TOP);
  
  // MIDI Subsystem
  textFont(mainFont);
  fill(255);
  text("MIDI >> " + midiSystem.status, midiX+2, midiY);
  stroke(255);
  line(midiX,midiY+19,midiX+385,midiY+19);
  
  // OSC Subsystem
  text("OSC >> " + "TODO ", oscX+2, oscY);
  line(oscX,oscY+19,oscX+385,oscY+19);
  
}

void setupArduino() {
  
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[ARDUINO_INDEX]);
  printlnToAll(millis() + ": Using Arduino at " + Arduino.list()[ARDUINO_INDEX]);
  
}

  

void printlnToAll(String in) {
  println(in);
  systemStatusLog.addLine(in);
}

// MIDI input event callback
void noteOneReceived(Note note) {
  // INPUT HANDLING HERE
  if (midiSystem.passthrough) {
    midiSystem.midiOut.sendNoteOn(midiSystem.getPassthroughChannel(), note.getPitch(), note.getVelocity());
  }
}
void noteOffReceived(Note note) {
  // INPUT HANDLING HERE
  if (midiSystem.passthrough) {
    midiSystem.midiOut.sendNoteOff(midiSystem.getPassthroughChannel(), note.getPitch(), note.getVelocity());
  }
}
class LMOsc extends OscP5 {
  LMOsc(Object p, int rxp) {
    super(p, rxp);
  }
}
/*********************
 * LMBeamControl class
 *********************/
class LMBeamControl {
  int divs;
  int base;
  int[] currScale;
  String status;
  String info;
  boolean enabled;
  int channel;
  int velocity;
  LMMidiControl midi;
  
  LMBeamControl(LMMidiControl mc) {
    midi = mc;
    enabled = false;
    status = "DISABLED";
    info = "SCALE: " + "foo" + " OCTV: " + "bar" + " BASE: " + base + " CHAN: " + channel ;
    channel = 1;
    velocity = 90;
    currScale = LMConstants.major;
    base = 60;
    divs = 7; // fix this, perhaps constructor arg, needs to match UI value at init
  }
  void octaveUp() {
    base += 12;
  }
  void octaveDn() {
    base -= 12;
  }
  void setOctave(int oct) {
    base = oct*12 + 12;
  }
  int getOctave() {
    return (base-12)/12;
    // TODO: THIS NEEDS FIXING. It does not work for base notes that are not C
  }
  void setBase(int nt) {
    base = nt;
  }
  int getBase() {
    return base;
  }
  void setChannel(int ch) {
    channel = ch;
  }
  int getChannel() {
    return channel;
  }
  void enable() {
    enabled = true;
  }
  void disable() {
    enabled = false;
    panic();
  }
 String getStatus() {
    return status;
  }
  void setScale(int[] scl) {
    currScale = scl;
  }
  int[] getScale() {
    return currScale;
  }
  void panic() {
    // This is a less powerful panic than LMMidiControl.panic(), as it only panics the current channel
    for (int nt=0;nt<128;nt++) {
        midi.midiOut.sendNoteOff(channel,nt,63);
    }
  }
  
}
/*********************
 * LMOscClient class
 *********************/
class LMOscClient extends NetAddress {
  private String address;
  private int port;
  // TODO: this whole class is broken, class needs to reinstantiate itself after addr/prt changed
  LMOscClient(String addr, int prt) {
    super(addr, prt);
    address = addr;
    port = prt;
  }
  void setAddress(String addr) {
    address = addr;
  }
  String getAddress() {
    return address;
  }
  void setPort(int prt) {
    port = prt;
  }
  int getPort() {
    return port;
  }
  void set(String addr, int prt) {
    address = addr;
    port = prt;
  }
}
/*********************
 * LMConstants class
 *********************/
static class LMConstants {
  // Because static fields are unallowed in non-top level types.
  static final String[] midiOffsets = {"C","C#","D","D#","E","F","F#","G","A","A#","B"};
  // Oh my dear mayonnaise, I love this guy: http://www.grantmuller.com/MidiReference/doc/midiReference/ScaleReference.html
  // TODO: consider switching to use enums
  static final int[] major = {0,2,4,5,7,9,11};
  static final int[] minor = {0,2,3,5,7,8,10};
  static final int[] chromatic = {0,1,2,3,4,5,6,7,8,9,10,11};
  static final int[] pentatonic = {0,2,4,7,9};
}
/*********************
 * LMMidiControl class
 *********************/
class LMMidiControl {
  MidiInput midiIn;
  MidiOutput midiOut;
  int midiInputDevice, midiOutputDevice;
  String status;
  boolean running;
  boolean passthrough; // if true, incoming midi will be echoed out
  int passthroughChannel; // the channel that incoming midi will be echoed out with
  int lastTestNote;
  
  LMMidiControl(int in, int out) {
    midiInputDevice = in;
    midiOutputDevice = out;
    running = false;
    status = "HALTED";
    start();
  }
  void sendNoteOn(int ch, int nt, int vel) {
    if (running) {
      midiOut.sendNoteOn(ch, nt, vel);
    }
  }
  void sendNoteOff(int ch, int nt, int vel) {
    if (running) {
      midiOut.sendNoteOff(ch, nt, vel);
    }
  }
  void start() {
    try {
      midiIn = RWMidi.getInputDevices()[midiInputDevice].createInput(this);
      printlnToAll("Started MIDI input device: " + RWMidi.getInputDevices()[midiInputDevice] );
    } catch(Exception e) {
      e.printStackTrace();
      printlnToAll("Failed to instantiate MIDI input device, device does not exist.");
    }
    try {
      midiOut = RWMidi.getOutputDevices()[midiOutputDevice].createOutput();
      printlnToAll("Started MIDI output device: " + RWMidi.getOutputDevices()[midiOutputDevice] );
    } catch(Exception e) {
      e.printStackTrace();
      printlnToAll("Failed to instantiate MIDI output device, device does not exist.");
    }
    running = true;
    status = "RUNNING";
  }
  void stop() { // Hammertime!
    panic();
    midiOut.closeMidi();
    running = false;
    status = "HALTED";
  }
  void panic() {
    if (running) {
      for (int ch=0;ch<16;ch++) {
        for (int nt=0;nt<128;nt++) {
            midiOut.sendNoteOff(ch,nt,63);
        }
      }
    }
  }
  void list() {
    println("Available MIDI output devices:");
    println(RWMidi.getOutputDevices());
    println("Available MIDI input devices:");
    println(RWMidi.getInputDevices());
  }
  void sendTestNoteOn() {
    if (running) {
      lastTestNote = LMConstants.minor[(int)random(LMConstants.minor.length)] + 60;
      midiOut.sendNoteOn(1,lastTestNote,90);
    }
  }
  void sendTestNoteOff() {
    if (running) {
      midiOut.sendNoteOff(1,lastTestNote,90);
    }
  }
  void setPassthroughChannel(int i) {
    passthroughChannel = constrain(i,1,16);
  }
  int getPassthroughChannel() {
    return passthroughChannel;
  }
}
/*******************************
 * LMDigitalSensor class
 *******************************/
class LMDigitalSensor {
  Arduino ar;
  int pin;
  
  final int AVERAGE_LENGTH;
  // TODO: Implement debounce/smoothing
  
  LMDigitalSensor(Arduino a, int p, int avgLen) {
    ar = a;
    pin = p;
    AVERAGE_LENGTH = 10;
    
  }
  void update() {
    // for updating debounce/smoothing routine, etc
  }
  boolean value() {
    // This method returns the boolean value of the pin, assuming active-high logic, i.e. 5V == true, 0V == false
    if (ar.digitalRead(pin) == Arduino.HIGH) {
      return true;
    }
    else {
      return false;
    }
  }
  int getPin() {
    return pin;
  }
  void setPin(int p) {
    pin = p;
  }
}

/*******************************
 * LMAnalogSensor class
 *******************************/
class LMAnalogSensor {
  Arduino ar;
  int pin;
  
  final int AVERAGE_LENGTH;
  float[] rawInput;
  int currentIndex;
  float dt, RC;
  
  
  LMAnalogSensor(Arduino a, int p, int avgLen) {
    ar = a;
    pin = p;
    AVERAGE_LENGTH = avgLen;
    rawInput = new float[AVERAGE_LENGTH];
    currentIndex = 0;
    dt = 2;
    RC = 0.6f;
  }
  
  void update() {
    rawInput[currentIndex] = ar.analogRead(pin);
    currentIndex ++;
    if (currentIndex >= AVERAGE_LENGTH) {
      currentIndex = 0;
    }
  }
  // NOTE: Do not trust!
  float getLPFAverage() {
    float sum = 0;
    for (int i = 0; i < AVERAGE_LENGTH; i++) {
      sum += lowpass(rawInput, dt, RC)[i];
    }
    return sum/AVERAGE_LENGTH;
  }
  // NOTE: This returns results, but they may not be accurate. TODO: Fix
  float[] lowpass(float[] x, float idt, float iRC) {
    int sampleSize = x.length;
    float[] y = new float[sampleSize];
    float alpha = idt/(iRC + idt);
    y[0] = x[0];
    for (int i = 1; i < sampleSize - 1; i++) {
      y[i] = alpha * x[i] + (1 - alpha) * y[i-1];
    }
    return y;
  }
  
  float getMedianAverage() {
    // Returns the mean average of the two middle-ish values of the input array
    float[] process = rawInput;
    Arrays.sort(process);
    return (process[(int)(AVERAGE_LENGTH/2)] + process[1+(int)(AVERAGE_LENGTH/2)])/2.00f;
  }
  int getValue() {
    return ar.analogRead(pin);
  }
  int getPin() {
    return pin;
  }
  void setPin(int p) {
    pin = p;
  }
}
/**************************
 * LMGPSensor class
 **************************/
class LMGPSensor extends LMAnalogSensor {
  
  LMGPSensor(Arduino a, int p, int avg) {
    
    super(a, p, avg);
  }
  
  float getCentimeters() {
    // may need to be tweaked depending on sensor response curve
    float adcValue = (float)ar.analogRead(pin);
    return 12343.85 * pow(adcValue,-1.15);
  }
  float getInches() {
    float adcValue = (float)ar.analogRead(pin);
    return (12343.85 * pow(adcValue,-1.15))/2.54;
  }
}

/**************************
 * LMDisplay abstract class
 **************************/
abstract class LMDisplay {
  int xPosition, yPosition;
  int displayWidth, displayHeight;
  
  void setPosition(int x, int y) {
    xPosition = x;
    yPosition = y;
  }
  int[] getPosition() {
    int[] pos = new int[2];
    pos[0] = xPosition;
    pos[1] = yPosition;
    return pos;
  }
  void setXPosition(int x) {
    xPosition = x;
  }
  void setYPosition(int y) {
    yPosition = y;
  }
  void setWidth(int w) {
    displayWidth = w;
  }
  int getWidth() {
    return displayWidth;
  }
  void setHeight(int h) {
    displayHeight = h;
  }
  int getHeight() {
    return displayHeight;
  }
}

/**************************
 * LMDisplayDivs class
 **************************/
class LMDisplayDivs extends LMDisplay {
  private int divisions;
  private color divsColor;
  private color outlineColor;
  private boolean isHorizontal;
  private float divSpacing;
  
  LMDisplayDivs(int x, int y) {
    xPosition = x;
    yPosition = y;
    displayWidth = 383;
    displayHeight = 6;
    divisions = 7;
    divsColor = color(4,104,154);
    outlineColor = color(4,104,154);
    isHorizontal = true;
    divSpacing = (float)displayWidth/(divisions+1);
  }
  // TODO: add support for isHorizontal = false
  void draw() {
    if (isHorizontal) {
      stroke(outlineColor);
      strokeWeight(1);
      line(xPosition,yPosition,xPosition+displayWidth,yPosition);
      divSpacing = (float)displayWidth/(divisions+1);
      stroke(divsColor);
      for (int i = 1; i <= divisions; i++) {
        line(xPosition+(i*divSpacing),yPosition,xPosition+(i*divSpacing),yPosition+displayHeight);
      }
      // end caps
      line(xPosition,yPosition,xPosition,yPosition+displayHeight);
      line(xPosition+displayWidth,yPosition,xPosition+displayWidth,yPosition+displayHeight);
    }
    else {
      // not implemented yet, do not use
      println("Vertical divisions not supported yet!");
    }
  }
  void setDivs(int d) {
    divisions = d;
  }
  int getDivs() {
    return divisions;
  }
  void setDivsColor(color c) {
    divsColor = c;
  }
  color getDivsColor() {
    return divsColor;
  }
  void setOutlineColor(color c) {
    outlineColor = c;
  }
  color getOutlineColor() {
    return outlineColor;
  }
  
  
}
  
/********************
 * LMDisplayBar class
 ********************/
class LMDisplayBar extends LMDisplay {
  private float value;
  private color barColor;
  private color outlineColor;
  private float maximum;
  private float minimum;
  private boolean isHorizontal;
  
  LMDisplayBar(int x, int y) {
    xPosition = x;
    yPosition = y;
    displayWidth = 383;
    displayHeight = 8;
    value = 0f;
    barColor = color(0,255,0);
    outlineColor = color(4,104,154);
    maximum = 200;
    minimum = 0;
    isHorizontal = true;
  }
  // TODO: add integrated title, setLabel, getLabel, labelColor, setLabelColor, getLabelColor
  void draw() {
    if (isHorizontal) {
      fill(0);
      stroke(outlineColor);
      rect(xPosition,yPosition, displayWidth, displayHeight);
      point(xPosition+displayWidth, yPosition + displayHeight); // thisisbecausetherectangledoesntwork.seriously.
      fill(barColor);
      noStroke();
      rect(xPosition+1, yPosition+1, map(constrain(value,minimum,maximum), minimum, maximum, 0, displayWidth-1), displayHeight-1);
      
    }
    else {
      fill(0);
      stroke(outlineColor);
      rect(xPosition,yPosition, displayWidth, displayHeight);
      // point(xPosition+displayWidth, yPosition + displayHeight); not sure if needed
      fill(barColor);
      noStroke();
      rect(xPosition+1, yPosition+1, displayWidth-1, map(constrain(value,minimum,maximum), minimum, maximum, 0, displayHeight-1));
    }
  }
  
  void setValue(float v) {
    value = v;
  }
  float getValue() {
    return value;
  }
  void setBarColor(color c) {
    barColor = c;
  }
  color getBarColor() {
    return barColor;
  }
  void setOutlineColor(color c) {
    outlineColor = c;
  }
  color getOutlineColor() {
    return outlineColor;
  }
  void setMax(float m) {
    maximum = m;
  }
  float getMax() {
    return maximum;
  }
  void setMin(float m) {
    minimum = m;
  }
  float getMin() {
    return minimum;
  }
  void setRange(float min, float max) {
    minimum = min;
    maximum = max;
  }
    
} 

/*********************
 * LMDisplayList class
 *********************/
class LMDisplayList extends LMDisplay {
  private int xPos;
  private int yPos;
  private int displayWidth;
  private int displayHeight;
  private String[] contents;
  private int contentsPointer;
  private color textColor;
  
  LMDisplayList(int x, int y) {
    xPosition = x;
    yPosition = y;
    displayWidth = 160;
    displayHeight = 80;
    // TODO: Set list contents length based on displayHeight/line height
    contents = new String[5];
    for (int i=0; i < contents.length; i++) {
      contents[i] = "";
    }
    textColor = color(255); // The default text color
  }
  
  void draw() {
    fill(textColor);
    textFont(smallFont);
    for (int i=0; i < contents.length; i++) {
      // TODO: Truncate string length if pixel length is greater than displayWidth
      text(contents[i], xPosition+2, yPosition + (textDescent()+textAscent())*(i+1)-textAscent()-1);
    }
  }
  void addLine(String s) {
    contents[contentsPointer] = s;
    contentsPointer ++;
    if (contentsPointer > contents.length-1) {
      contentsPointer = 0;
    }
  }
  String getLine(int index) {
    return contents[index];
  }
  void setTextColor(color c) {
    textColor = c;
  }
  color getTextColor() {
    return textColor;
  }
}
  
