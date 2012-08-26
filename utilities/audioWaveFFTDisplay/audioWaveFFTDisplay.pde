import processing.opengl.*;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

/*********************************************************************************\
 * A tool for finding resonant frequencies, primarily feedback in live sound.    *
 * Note that this tool does NOT give an accurate display of relative amplitudes. *
 * Using OPENGL for graphics speed, and Minim for audio                          *
 * Author: Akira Youngblood                                                      *
 * Development Begun 2012-07-23                                                  *
\*********************************************************************************/

PFont font;
ControlP5 cp5;
Minim minim;
FFT fft;
AudioInput input;

Slider yScale, thresh;
float fftAmp, labelThresh;
float cursorFreq=0, cursorAmp=0;
boolean drawCross = false;

void setup() {
  size(960,640,OPENGL);
  smooth();
  frameRate(240);
  
  cp5 = new ControlP5(this);
  yScale = cp5.addSlider("Y_MULT")
    .setPosition(width-200,height-30)
    .setSize(150,10)
    .setValue(32)
    .setRange(1,120)
    ;
  thresh = cp5.addSlider("THRESH")
    .setPosition(width-200,height-44)
    .setSize(150,10)
    .setValue(200)
    .setRange(1,height/2-8)
    ;
  
  startMinimAudio();
}
void draw() {
  background(0);
  fftAmp = yScale.getValue();
  labelThresh = thresh.getValue();
  // draw FFTs
  fill(#ff0000);
  textAlign(LEFT);
  drawFFTAt(10,height/2,width-20);
  // draw stat
  cursorFreq = fft.indexToFreq((int)map(mouseX,10,width-20,0,fft.specSize()));
  cursorAmp = fft.getBand((int)map(mouseX,10,width-20,0,fft.specSize()));
  fill(#00ff00);
  textAlign(RIGHT);
  text(nf(cursorFreq,0,4) + " Hz",width-10,30);
  text(nf(cursorAmp,0,4) + " raw", width-10,50);
  text(nf(frameRate,0,3) + " fps",width-10,70);
  if (drawCross) {
    stroke(#ff00FF);
    line(mouseX,10,mouseX,height-10);
    line(10,mouseY,width-10,mouseY);
  }
}

void drawFFTAt(int x, int y, int w) {
  fft.forward(input.left);
  stroke(#00ffaa);
  for (int i=0; i<fft.specSize(); i++) {
    stroke(map(i,0,fft.specSize()/2,0,255), 0xFF, 0xAA);
    if(constrain(fft.getBand(i)*fftAmp*(i/50f+1),0,height/2-10) > labelThresh) {
      stroke(#ff0000);
      text(nf(fft.indexToFreq(i),0,1),map(i,0,fft.specSize(),0,w),13);
    }
    line(map(i,0,fft.specSize(),0,w)+x,y,map(i,0,fft.specSize(),0,w)+x,y-constrain(fft.getBand(i)*fftAmp*log(i+1.7),0,height/2-10));
  }
  fft.forward(input.right);
  stroke(#00aaff);
  for (int i=0; i<fft.specSize(); i++) {
    stroke(map(i,0,fft.specSize()/2,0,255), 0xAA, 0xFF);
    if(constrain(fft.getBand(i)*fftAmp*(i/50f+1),0,height/2-10) > labelThresh) {
      stroke(#ff0000);
      text(nf(fft.indexToFreq(i),0,1),map(i,0,fft.specSize(),0,w),height-8);
    }
    line(map(i,0,fft.specSize(),0,w)+x,y,map(i,0,fft.specSize(),0,w)+x,y+constrain(fft.getBand(i)*fftAmp*log(i+1.7),0,height/2-10));  
  }
}

void startMinimAudio() {
  minim = new Minim(this);
  input = minim.getLineIn();
  fft = new FFT(input.bufferSize(),input.sampleRate());
  println(millis() + ": Audio Started");
}
void mousePressed() {
  drawCross = !drawCross;
}

void exit() {
  input.close();
  minim.stop();
  super.stop();
  System.exit(0);
}
