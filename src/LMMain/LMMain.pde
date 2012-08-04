import cc.arduino.*;
import processing.serial.*;
import controlP5.*;
import rwmidi.*;

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

LMMidiControl midiSystem;

LMDisplayList systemStatusLog;

// Beam 1
DropdownList b1BaseNote, b1Scale, b1Mod, b1MidiChannel;
Numberbox b1DivisionsBox;
int b1Divisions;
LMDisplayBar beam1RawBar, beam1FiltBar;


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
  
  // System
  super.stop();
  println( millis() + ": super.stop() called. User must destroy window.");
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
  systemStatusLog = new LMDisplayList(500,40);
  
  
  // Beam 1
  cp5.addButton("enable B1")
    .setPosition(10,35)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
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
          //
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
          //
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
          //
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
          //
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
          //
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
  b1DivisionsBox = cp5.addNumberbox("b1Divisions")
    .setPosition(11,101)
    .setSize(29,18)
    .setValue(7)
    .setMin(1)
    .setMax(23)
    .setMultiplier(0.0625)
    .setCaptionLabel("")
    ;
  cp5.addTextlabel("foobar")
    .setPosition(42,102)
    .setValue("DIVS")
    ;
  beam1RawBar = new LMDisplayBar(11,131);
  beam1FiltBar = new LMDisplayBar(11, 141);
  
  // MIDI
  cp5.addButton("start MIDI")
    .setPosition(10,360)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
    ;
  cp5.addButton("stop MIDI")
    .setPosition(80,360)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
    ;
  cp5.addButton("panic MIDI")
    .setPosition(150,360)
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
    .setPosition(220,360)
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
    .setPosition(10,390)
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
    .setPosition(80,390)
    .setSize(60,20)
    .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_RELEASED) {
          //
        }
      }
    })
    ;
  
  
}
// For redrawing anything that needs to be redrawn
void updateGUI() {
  strokeWeight(1);
  stroke(255);
  textFont(smallFont);
  // Top bar
  fill(255);
  stroke(255);
  text("FPS: " + nf(frameRate,3,1),10,500);
  text("MX: " + nf(mouseX,4,0), 80, 500);
  text("MY: " + nf(mouseY,4,0), 145, 500);
  
  // Main system
  systemStatusLog.draw();
  
  // Beam 1
  fill(255);
  textFont(mainFont);
  text("BEAM 1 >> HALTED", 10, 10);
  stroke(255);
  line(10,29,395,29);
  
  fill(2,52,77); noStroke();
  rect(10,75,385,20);
  fill(255);
  textFont(smallFont);
  text("KEY: C# MAJOR  OCTV: 4  BASE NOTE: 60  CHAN: 12",14,79);
  stroke(4,104,154);
  line(53,112,53,122);
  line(10,122,395,122);
  
  textFont(smallFont);
  // beam1RawBar.setValue(foo.raw);
  beam1RawBar.draw();
  // beam1FiltBar.setValue(foo.filt);
  beam1FiltBar.draw();
  
  // MIDI Subsystem
  stroke(255);
  line(10,350,320,350);
  textFont(mainFont);
  fill(255);
  text("MIDI >> " + midiSystem.status, 10, 330);
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

// MIDI input event handlers
void noteOneReceived(Note note) {
  //
  if (midiSystem.passthrough) {
    midiSystem.midiOut.sendNoteOn(1, note.getPitch(), note.getVelocity());
  }
}
void noteOffReceived(Note note) {
  //
  if (midiSystem.passthrough) {
    midiSystem.midiOut.sendNoteOff(1, note.getPitch(), note.getVelocity());
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
  int lastTestNote;
  
  LMMidiControl(int in, int out) {
    midiInputDevice = in;
    midiOutputDevice = out;
    running = false;
    status = "HALTED";
    start();
  }
  
  void sendNoteOn(int ch, int nt, int vel) {
    midiOut.sendNoteOn(ch, nt, vel);
  }
  void sendNoteOff(int ch, int nt, int vel) {
    midiOut.sendNoteOff(ch, nt, vel);
  }
  
  void start() {
    midiIn = RWMidi.getInputDevices()[midiInputDevice].createInput(this);
    printlnToAll("Started MIDI input device: " + RWMidi.getInputDevices()[midiInputDevice] );
    midiOut = RWMidi.getOutputDevices()[midiOutputDevice].createOutput();
    printlnToAll("Started MIDI output device: " + RWMidi.getOutputDevices()[midiOutputDevice] );
    running = true;
    status = "RUNNING";
  }
  void stop() {
    midiOut.closeMidi();
    running = false;
    status = "HALTED";
  }
  void panic() {
    for (int ch=0;ch<16;ch++) {
      for (int nt=0;nt<128;nt++) {
          midiOut.sendNoteOff(ch,nt,63);
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
    lastTestNote = LMConstants.minor[(int)random(LMConstants.minor.length)] + 60;
    midiOut.sendNoteOn(1,lastTestNote,90);
  }
  void sendTestNoteOff() {
    midiOut.sendNoteOff(1,lastTestNote,90);
  }
}

/*******************************
 * LMAnalogSensor abstract class
 *******************************/
class LMAnalogSensor {
  Arduino ar;
  int pin;
  
  final int AVERAGE_LENGTH;
  float[] rawInput;
  int currentIndex;
  float dt, RC;
  
  
  LMAnalogSensor(Arduino a, int p, int avg) {
    ar = a;
    pin = p;
    AVERAGE_LENGTH = avg;
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
      fill(barColor);
      noStroke();
      rect(xPosition+1, yPosition+1, map(constrain(value,minimum,maximum), minimum, maximum, 0, displayWidth-1), displayHeight-1);
      
    }
    else {
      fill(0);
      stroke(outlineColor);
      rect(xPosition,yPosition, displayWidth, displayHeight);
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
  
