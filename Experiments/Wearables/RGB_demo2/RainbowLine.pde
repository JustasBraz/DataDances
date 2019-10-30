float colourdegrees = 0;

class RainbowLine {
  int x, y, px, py;
  float off;
  RainbowLine() {
    x=mouseX;
    y=mouseY;
    px=pmouseX;
    py=pmouseY;
    off=colourdegrees;
  }
  void draw() {
    stroke( (colourdegrees+off)%360, 97, 100);
    line(x, y, px, py);
  }
}
