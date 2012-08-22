import processing.opengl.*;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

/*********************************************************************************\
 * Displays a realtime spectrogram of incoming audio content                     *
 * Note that this tool does NOT give an accurate display of relative amplitudes. *
 * Using OPENGL for graphics speed, and Minim for audio                          *
 * Author: Akira Youngblood                                                      *
 * Development Begun 2012-08-18                                                  *
\*********************************************************************************/

PFont font;
Minim minim;
FFT fft;
AudioInput input;
int xpos = 10;

void setup() {
  size(2300,1350,OPENGL);
  frame.setResizable(true);
  smooth();
  frameRate(240);
  textAlign(RIGHT);
  startMinimAudio();
  background(0);
}
void draw() {
  fill(0);
  rect(width-10,10,-50,20);
  fill(127);
  text(nf(frameRate,0,1),width-12,20);
  drawFFTLineAt(xpos, 10, height-20);
  if (xpos > width-10) {background(0); xpos=10;} else {xpos++;}
}
void drawFFTLineAt(int x, int y, int h) {
  fft.forward(input.mix);
  stroke(#00ffff);
  for (int i=0; i<fft.specSize(); i++) {
    if (fft.getBand(i) < .8) {
      stroke(0,0,fft.getBand(i)*2000);
    }
    else {
      stroke(0,fft.getBand(i)*500,255);
    }
    if (fft.getBand(i) > 2) {
      stroke(fft.getBand(i)*30,180,0);
    }
    point( x, h-map(i,0,fft.specSize(), 0, h) + y);
  }
}
void startMinimAudio() {
  minim = new Minim(this);
  input = minim.getLineIn();
  fft = new FFT(input.bufferSize(),input.sampleRate());
}
void exit() {
  // Because we need to close the audio input and stop Minim, we override the P5 exit() method.
  // By using System.exit(0), we make the window disappear.
  input.close();
  minim.stop();
  super.stop();
  System.exit(0);
}
void mouseReleased() {
  background(0);
  xpos = 10;
  fill(0);
}
