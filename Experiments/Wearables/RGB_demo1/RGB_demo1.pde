int h = 0;
float x = 0;

void setup() {
  size(500, 500);
  background(0);
  colorMode(HSB, 360, 360, 360);
}

void draw() {
  if (h > 360) {
    h = 0;
  }
  h += 1;

  strokeWeight(10);
  stroke(changeColor(h, 16), 360, 360);
  //point(mouseX, mouseY);
  //point(pmouseX, pmouseY);
  line(mouseX, mouseY, pmouseX, pmouseY);
}

int changeColor(int step, int bits) {



  switch(bits) {
  case 2:
    if ((h>0) && (h<=90)) {
      return 0;
    }
    if ((h>90) && (h<=180)) {
      return 90;
    }
    if ((h>180) && (h<=270)) {
      return 180;
    }
    if ((h>270) && (h<=360)) {
      return 270;
    }

    break;
  case 4:
    if ((h>0) && (h<=72)) {
      return 0;
    }
    if ((h>72) && (h<=144)) {
      return 72;
    }
    if ((h>144) && (h<=216)) {
      return 144;
    }
    if ((h>216) && (h<=288)) {
      return 216;
    }
    if ((h>288) && (h<=360)) {
      return 288;
    }
    break;
    case 8:
    if ((h>0) && (h<=45)) {
      return 0;
    }
    if ((h>45) && (h<=90)) {
      return 45;
    }
    if ((h>90) && (h<=135)) {
      return 135;
    }
    if ((h>135) && (h<=180)) {
      return 180;
    }
    if ((h>180) && (h<=235)) {
      return 235;
    }
    if ((h>235) && (h<=270)) {
      return 270;
    }
    if ((h>270) && (h<=315)) {
      return 315;
    }
    if ((h>315) && (h<=360)) {
      return 360;
    }
    break;
  case 16: 
    if ((h>0) && (h<=22)) {
      return 0;
    }
    if ((h>22) && (h<=44)) {
      return 22;
    }
    if ((h>44) && (h<=66)) {
      return 44;
    }
    if ((h>66) && (h<=88)) {
      return 66;
    }
    if ((h>88) && (h<=110)) {
      return 88;
    }
    if ((h>110) && (h<=132)) {
      return 110;
    }
    if ((h>132) && (h<=154)) {
      return 132;
    }
    if ((h>154) && (h<=176)) {
      return 154;
    }
    if ((h>176) && (h<=198)) {
      return 176;
    }
    if ((h>198) && (h<=220)) {
      return 198;
    }
    if ((h>220) && (h<=242)) {
      return 220;
    }
    if ((h>242) && (h<=264)) {
      return 242;
    }
    if ((h>264) && (h<=286)) {
      return 264;
    }
    if ((h>286) && (h<=308)) {
      return 286;
    }
    if ((h>308) && (h<=330)) {
      return 308;
    }
    if ((h>330) && (h<=360)) {
      return 330;
    }

    break;
  }
  return 0;
}
