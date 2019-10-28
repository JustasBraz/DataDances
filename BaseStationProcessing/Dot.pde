//This class is used to determine and visualise the end points of each
//sensor value.

//The creation of this class was deemed necessary, as it was the easiest 
//way to determine if e.g. the sensor values were matching some shape on screen
class Dot { 
  
  float xpos, ypos; 
  int name;
  int ellipseSize=10;
  float threshold=70;
  color filler=color(0, 76, 153);
  int alpha=100;
  
  Dot (float x, float y, int i) {  
    ypos = y; 
    xpos = x;
    name=i;
  } 
  boolean matchingEllipse() {

    if (abs(250-dist(0, 0, xpos, ypos))<threshold) {
      return true;
    } else {
      return false;
    }
  }

  void setPos(float x, float y) {
    ypos = y; 
    xpos = x;
  }
  
  void display() {
    stroke(filler, alpha);
    fill(0, 102, 153, 51);
    textSize(20);
    ellipse(xpos, ypos, ellipseSize, ellipseSize);
    text(name, xpos+10, ypos+10);
  }
}
