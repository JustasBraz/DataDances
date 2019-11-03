PImage img;
Bubble[] bubbles;
int unit = 40;
int count;
void setup() {
  // Images must be in the "data" directory to load correctly
  size(400,400);
  img = loadImage("sunflower.jpg");
  
  noStroke();
  int wideCount = width / unit;
  int highCount = height / unit;
  count = wideCount * highCount;
  bubbles = new Bubble[count];

  int index = 0;
  for (int y = 0; y < highCount; y++) {
    for (int x = 0; x < wideCount; x++) {
      bubbles[index++] = new Bubble(x*unit, y*unit, 50);
    }
  }
  
}

void draw() {
  image(img, 0, 0);
  
  for (int i=0; i<bubbles.length; i++) {
    bubbles[i].display();
   // mod.display();
   
   if(dist(mouseX,mouseY,bubbles[i].getX(), bubbles[i].getY())<50){
     bubbles[i].remove();
   }
  }
}
