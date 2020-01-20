//This class is used for the GUI (buttons on the top left corner of the screen)
//to change the mode of visualisation

class Button { 
  
  float xpos, ypos; 
  int mode;
  float size=50;
  color filler=color(0, 76, 153);
  int alpha=100;
  
  Button (float x, float y, int i) {  
    ypos = y; 
    xpos = x;
    mode=i;
  } 
  
  boolean activate() {
    if (dist(mouseX, mouseY, xpos+width/2, ypos+height/2)<size/2) {
      visualiseOn();

   return true;
    } else {
      visualiseOff();
   return false;
    }
  }
  
  int getMode() {
    return mode;
  }
  
  void visualiseOff() {
    fill(0, 50);
    text(mode, xpos-7, ypos+8);
    fill(230, 5);
    ellipse(xpos, ypos, size, size);
    noFill();
  }
  
  void visualiseOn() {
    fill(0);
    text(mode, xpos-7, ypos+8);
    fill(255, 50, 50, 15);

    ellipse(xpos, ypos, size, size);
    noFill();
  }
}
