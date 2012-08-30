
int xPos = 0;
PImage img;

void setup() {
  size(1024,768);
  img = loadImage("input.jpg");
}
void draw() {
  background(0);
  image(img,0,0);
  loadPixels();
  color result = get(xPos,7);
  fill(result); noStroke();
  rect(64,64,64,64);
  xPos++;
  if (xPos > 7) {xPos = 0;}
  delay(100);
}


