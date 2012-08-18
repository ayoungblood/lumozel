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

float fftAmp = 32;
float cursorFreq=0, cursorAmp=0;
int zpos = 0;
int xpos = 10;

void setup() {
  size(2300,1350,OPENGL);
  frame.setResizable(true);
  smooth();
  frameRate(240);
  
  startMinimAudio();
  background(0);
}
void draw() {
  //rotate(30);
  // translate(width/2,height/2);
  // draw FFTs
  fill(#ff0000);
  textAlign(LEFT);
  drawFFTLineAt(xpos, 10, height-20);
  // draw stat
  /*
  cursorFreq = fft.indexToFreq((int)map(mouseX,10,width-20,0,fft.specSize()));
  cursorAmp = fft.getBand((int)map(mouseX,10,width-20,0,fft.specSize()));
  fill(#00ff00);
  textAlign(RIGHT);
  text(nf(cursorFreq,0,4) + " Hz",width-10,30);
  text(nf(cursorAmp,0,4) + " raw", width-10,50);
  text(nf(frameRate,0,3) + " fps",width-10,70);
  
  */
  xpos ++;
  if (xpos > width-10) {
    background(0);
    xpos=10;
  }
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
  println(millis() + ": Audio Started");
}

void exit() {
  // Because we need to close the audio input and stop Minim, we override the P5 exit() method.
  // A side-effect of this is that the window will not destroy itself automagically.
  input.close();
  minim.stop();
  super.stop(); // Hammertime!
  System.exit(0);
}

