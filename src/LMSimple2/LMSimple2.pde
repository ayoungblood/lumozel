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

void setup() {
  size(640,480,P2D);
  smooth();
  frameRate(480);
  textMode(SCREEN);
  font = createFont("Arial", 12, true);
  textFont(font);
  setupArduino(0);
  setupMidi(3);
  setupOsc(8000,"10.0.1.25",9000);
  //logfile = createWriter("log.txt");
  //logfile.print("Started at " + (int)(System.currentTimeMillis()/1000L) + "\n\n");
}
void draw() {
  background(0);
  
}

// Incoming OSC event callback
void oscEvent(OscMessage in) {
  String tt = in.typetag();
  if (tt == "i" || tt == "f" || tt == "s") {
    
  }
  else {
    println("OSC message with unrecognized typetag: " + tt);
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

