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
  size(960,640,OPENGL);
  smooth();
  
  minim = new Minim(this);
  input = minim.getLineIn();
  fftLog = new FFT(input.bufferSize(), input.sampleRate());
  fftLog.linAverages(8);
  
  wf = new WaterfallController();
  
}

void draw() {
  background(0);
  translate(0,height/2+80,-250);
  rotateX(HALF_PI-.2-(.4*sin(frameCount/130f)));
  rotate(-.4+(.2*sin(frameCount/70f)));
  wf.display();
  
}


class WaterfallController {
  public int[][] samples;
  
  WaterfallController() {
    samples = new int[8][8];
    
  
    for (int i=0; i < 8; i++) {
      for (int j=0; j < 8; j++) {
        samples[i][j] = i*j;
      }
    }
  }
  void update() {
    
  }
  void display() {
    fill(255);
    noStroke();
    fftLog.forward(input.mix);
    for (int i=0; i < 8; i++) {
      for (int j=0; j < 8; j++) {
        pushMatrix();
        translate(i*16,j*16,0);
        translate(0,0,fftLog.getAvg(i)*32*((i/8)+1));
        fill(fftLog.getAvg(i)*((i/8)+1)*200,255-fftLog.getAvg(i)*((i/8)+1)*1000,fftLog.getAvg(i)*((i/8)+1)*200);
        box(10,10,fftLog.getAvg(i)*128*((i/8)+1));
        popMatrix();
      }
    }
  }
  
}
void exit() {
  input.close();
  minim.stop();
  super.stop();
  System.exit(0);
}
    
