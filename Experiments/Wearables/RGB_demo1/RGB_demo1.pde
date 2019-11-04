float h = 0;
float STEP_SIZE=0.1;
int BITS=4; //try 1,2,4,8

void setup() {
  size(500, 500);
  background(0);
  colorMode(HSB, 360, 360, 360);
  smooth();
}

void draw() {
  if (mousePressed) {
    if (h > 360) {
      h = 0;
    }
    h += STEP_SIZE;
    
    strokeWeight(15);
    println(getRainbow(BITS, h));
    stroke(getRainbow(BITS, h), 360, 360);
    line(mouseX, mouseY, pmouseX, pmouseY);
  }
}

void record() {
  if (frameCount%17==0) {
    saveFrame("RGB_16bit/"+frameCount+".png");
  }
}

int getRainbow(int bits, float step) {
  //change of colors becomes too slow for large bit values
  if (bits==8) {
    step*=10;
  }

  step=floor(step);
  float n = pow(2, bits);
  return int((step*360/n)%360);
}
