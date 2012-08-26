import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

/*********************************************************************************\
 * Displays a realtime waterfall plot of incoming audio                          *
 * Note that this tool does NOT give an accurate display of relative amplitudes. *
 * Using OPENGL for graphics speed, and Minim for audio                          *
 * Author: Akira Youngblood                                                      *
 * Development Begun 2012-08-22                                                  *
\*********************************************************************************/

Minim minim;
AudioInput input;
FFT fftLog;

WaterfallController wf;

void setup() {
  size(1024,768,OPENGL);
  frameRate(400);
  smooth();
  
  // Start Minim audio
  minim = new Minim(this);
  input = minim.getLineIn();
  fftLog = new FFT(input.bufferSize(), input.sampleRate());
  fftLog.linAverages(32);
  
  wf = new WaterfallController();
}

void draw() {
  background(0);
  fill(180);
  text(frameRate,15,25);
  fftLog.forward(input.mix);
  float[] newSamps = new float[32];
  for (int i=0; i < newSamps.length; i++) {
    newSamps[i] = fftLog.getAvg(i)*50*log(i+1.7);
  }
  wf.add(newSamps);
  
  wf.display();
}


class WaterfallController {
  public float[][] samples;
  private int fWidth = 32;
  private int tLength = 64;
  private int index = 0;
  
  WaterfallController() {
    samples = new float[tLength][fWidth];
    
    for (int t=0; t < tLength; t++) {
      for (int f=0; f < fWidth; f++) {
        samples[t][f] = 0;
      }
    }
  }
  void add(float[] in) {
    if (in.length == fWidth) {
      samples[index] = in;
      index++;
    }
    else {
      background(255,0,0);
    }
    if (index > tLength-1) {
      index = 0;
    }
  }
  void display() {
    pushMatrix();
    translate(width/2+500,height/2+80,0);
    rotate(PI);
    rotateX(-HALF_PI+.6);
    fftLog.forward(input.mix);
    stroke(0);
    colorMode(HSB,255);
    for (int t=0; t < tLength; t++) {
      for (int f=0; f < fWidth; f++) {
        pushMatrix();
        translate(t*16,f*16,samples[t][f]/8);
        fill(samples[t][f]*1.2,255,samples[t][f]*4f+40);
        box(8,8,samples[t][f]);
        popMatrix();
      }
    }
    colorMode(RGB,255);
    popMatrix();
  }
}
void exit() {
  // Stop audio, stop Processing, and then stop the VM
  input.close();
  minim.stop();
  super.stop();
  System.exit(0);
}
    
