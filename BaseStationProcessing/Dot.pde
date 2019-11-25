//This class is used to determine and visualise the end points of each
//sensor value.

//The creation of this class was deemed necessary, as it was the easiest 
//way to determine if e.g. the sensor values were matching some shape on screen
class Dot { 

  PVector startCoord=new PVector();
  PVector endCoord=new PVector();
  int name;
  int ellipseSize=10;
  float threshold=70;
  color filler=color(0, 76, 153);
  int alpha=100;
  int state=0;
  float intensity;
  
  final float ROOM_SIZE = 150.0; //SET TO 300 OUTSIDE UCLIC

  Dot (PVector a, int i) {  
    startCoord.x=0;
    startCoord.y=0;

    endCoord.x = a.x; 
    endCoord.y = a.y;
    name=i;
  } 

  boolean matchingEllipse() {

    if (abs(250-dist(startCoord.x, startCoord.y, getPos().x, getPos().y))<threshold) {
      return true;
    } else {
      return false;
    }
  }
  
  PVector getPos() {
    return new PVector(endCoord.x*intensity, endCoord.y*intensity);
  }

  void setPos(float input) {
    intensity=input;
  }

  void checkBinaryThreshold() {
    if (state == 0 && intensity < ROOM_SIZE * 0.9) {
      state = 1;
    } else if (state == 1 && intensity > ROOM_SIZE * 1.1) {
      state = 0;
    }
    
    if (state == 1) {
      stroke(255);
      strokeWeight(8);
      fill(255);
      setPos(300);
    } else {
      stroke(0);
      strokeWeight(1);
      noFill();
    }
  }
  
  void displayState() {
    textSize(25);
    fill(255);
    text(state, endCoord.x*350, endCoord.y*350);
  }
 
  void display() {
    stroke(filler, alpha);
    fill(0, 102, 153, 51);
    textSize(20);
    ellipse(getPos().x, getPos().y, ellipseSize, ellipseSize);
    text(name, getPos().x+10, getPos().x+10);
  }
}
