//This class is used for the GUI (buttons on the top left corner of the screen)
//to change the mode of visualisation

class Button {

  float xpos, ypos;
  int mode;
  float size = 50;
  color filler = color(0, 76, 153);
  int alpha = 100;
  int inverseColors = 0;

  Button(float x, float y, int i) {
    ypos = y;
    xpos = x;
    mode = i;
  }

  boolean activate(String colorMode) {
    if (colorMode == "inverse") {
      inverseColors = 1;
    } else inverseColors = 0;

    if (dist(mouseX, mouseY, xpos + width / 2, ypos + height / 2) < size / 2) {
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
    if (inverseColors == 0) {
      fill(0, 50);
      text(mode, xpos - 7, ypos + 8);
      fill(230, 5);
    } else {
      fill(255, 50);
      text(mode, xpos - 7, ypos + 8);
      fill(0, 5);
    }

    ellipse(xpos, ypos, size, size);
    noFill();
  }

  void visualiseOn() {
    if (inverseColors == 0) {
      fill(0);
      text(mode, xpos - 7, ypos + 8);
      fill(255, 50, 50, 15);
    } else {
      fill(255);
      text(mode, xpos - 7, ypos + 8);
      fill(255, 50);
    }

    ellipse(xpos, ypos, size, size);
    noFill();
  }
}
