
int xPos = 0;
PImage img;

void setup() {
  size(1024,768);
  img = loadImage("input.jpg");
}
void draw() {
  background(0);
  image(img,0,0);
  
}


