class Bubble {
  int xpos;
  int ypos;
  float size;

  Bubble(int tempXpos, int tempYpos, float tempSize) {    
    xpos = tempXpos;   
    ypos = tempYpos;   
    size=tempSize;
  }
  void display() {
    fill(0);
    ellipse(xpos, ypos,size, size);
  }
  int getX(){
  return xpos;}
  
  int getY(){return ypos;}
}
