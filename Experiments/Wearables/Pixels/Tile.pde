
class Tile {
  float x, y;
  float w;
  int col;
  int prevCol;
  int id=0;
  int lastReversed=millis();
  float nudge;
  Tile (float tempX, float tempY, float tempSide, int tempCol) {
    x = tempX;
    y = tempY;
    w = tempSide;
    col = tempCol;
  }

  void display() {
    stroke(200);
   // rectMode(CENTER);
    //noStroke();
    fill(col);
    rect (x, y, w, w);
  }

  void black() {
    col = color (0) ;
  }

  void checkMouse() {
    if (mouseX > x & mouseX < x+w & mouseY > y & mouseY < y+w) {
      int waitTime=1000;
      if (id==0&&(abs(millis()-lastReversed)>waitTime)) {
        col=color(100);
        id=1;
        this.lastReversed=millis();
      }

      if ((id==1)&&abs((millis()-lastReversed))>waitTime) {
        col=color(255);
        id=0;
        lastReversed=millis();
      }

      println(x, y, abs((millis()-this.lastReversed)));
    }
  }

  void displayID() {
    int off=5;


    fill(0);
    textSize(22);

    if (this.id==1) {
      fill(255);
    } else {
      fill(0);
    }
    fill(255, 0, 0);
    text(id, x-off, y+off);
    noStroke();
  }
}
