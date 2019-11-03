
class Tile {
  float x, y;
  float w;
  int col;
  int prevCol;
  int id=0;
  Tile (float tempX, float tempY, float tempSide, int tempCol) {
    x = tempX;
    y = tempY;
    w = tempSide;
    col = tempCol;
  }

    void display() {
    //stroke(220);
    noStroke();
    fill(col);
    rect (x, y, w, w);
  }

  void black() {
    col = color (0) ;
  }
  
  void checkMouse(){
 if (mouseX > x & mouseX < x+w & mouseY > y & mouseY < y+w) {
   col=color(0);
   id=1;
   prevCol=col;
 } 
 }
 
 void displayID(){
   if(mousePressed){
   
   fill(0);
   stroke(0);
   text(id, x,y);
   noStroke();
   col=color(200);
 }
 else{
   col=prevCol;
 }
 }
}
