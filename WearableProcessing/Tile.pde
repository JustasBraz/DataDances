
class Tile {
  float x, y;
  float w;
  int col;
  int prevCol;
  int id=0;
  int lastReversed=millis();
  int lastSwitch=millis();
  int clearAfter = 3000;
  float nudge;
  
  Tile (float tempX, float tempY, float tempSide, int tempCol) {
    x = tempX;
    y = tempY;
    w = tempSide;
    col = tempCol;
  }
 
  void display() {
    //stroke(360);
    rectMode(CENTER);
    noStroke();
    fill(col);
    rect (x, y, w, w);
    if (millis() - lastReversed > clearAfter) {
      black();
    }
  }

  void black() {
    col = color (0) ;
    id=0;
  }


  void checkMouse() {
    if (mouseX > x & mouseX < x+w & mouseY > y & mouseY < y+w) {
      int waitTime=1000;
      if (id==1&&(abs(millis()-lastReversed)>waitTime)) {
        col=color(0);
        id=0;
        this.lastReversed=millis();
      }

      if ((id==0)&&abs((millis()-lastReversed))>waitTime) {
        col=color(360);
        id=1;
        this.lastReversed=millis();
      }

      println(x, y, abs((millis()-this.lastReversed)));
    }
  }
  void checkWearable(float coordX, float coordY) {
    coordX+=width/2;
    coordY+=height/2;
    if (coordX > x & coordX < x+w & coordY > y & coordY < y+w) {
      int waitTime=1000;
      if (id==1&&(abs(millis()-lastReversed)>waitTime)) {
        col=color(0);
        id=0;
        this.lastReversed=millis();
      }

      if ((id==0)&&abs((millis()-lastReversed))>waitTime) {
        col=color(360);
        id=1;
        this.lastReversed=millis();
      }

      //println(x, y, abs((millis()-this.lastReversed)));
    }
  }

  void displayID() {
    int off=5;


    fill(0);
    textSize(22);

    if (this.id==1) {
      fill(360);
    } else {
      fill(0);
    }
    fill(0, 360,360);
    text(id, x-off, y+off);
    noStroke();
  }
}
