int h = 0;
float x = 0;

void setup() {
  size(500, 500);
  background(0);
  colorMode(HSB, 360, 360, 360);
  smooth();
}

void draw() {
  if(frameCount%17==0){
  saveFrame("RGB_16bit/"+frameCount+".png");
  }
  if(mousePressed){
  if (h > 360) {
    h = 0;
  }
  h += 1;

  strokeWeight(15);
  stroke(changeColor(h, 4), 360, 360);
  //point(mouseX, mouseY);
  //point(pmouseX, pmouseY);
  line(mouseX, mouseY, pmouseX, pmouseY);}
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

    case 3:
    if ((h>0) && (h<=52)) {
      return 0;
    }
    if ((h>52) && (h<=104)) {
      return 52;
    }
    if ((h>104) && (h<=156)) {
      return 104;
    }
    if ((h>156) && (h<=208)) {
      return 156;
    }
    if ((h>208) && (h<=260)) {
      return 208;
    }
    if ((h>260) && (h<=302)) {
      return 260;
    }
    if ((h>302) && (h<=354)) {
      return 302;
    }

    break;
  case 4: 
    if ((h>0) && (h<=21)) {
      return 0;
    }
    if ((h>21) && (h<=42)) {
      return 21;
    }
    if ((h>42) && (h<=63)) {
      return 42;
    }
    if ((h>63) && (h<=84)) {
      return 63;
    }
    if ((h>84) && (h<=105)) {
      return 84;
    }
    if ((h>105) && (h<=126)) {
      return 105;
    }
    if ((h>126) && (h<=147)) {
      return 126;
    }
    if ((h>147) && (h<=168)) {
      return 147;
    }
    if ((h>168) && (h<=189)) {
      return 168;
    }
    if ((h>189) && (h<=210)) {
      return 189;
    }
    if ((h>210) && (h<=231)) {
      return 210;
    }
    if ((h>231) && (h<=252)) {
      return 231;
    }
    if ((h>252) && (h<=273)) {
      return 252;
    }
    if ((h>273) && (h<=294)) {
      return 273;
    }
    if ((h>294) && (h<=315)) {
      return 294;
    }
    if ((h>315) && (h<=336)) {
      return 315;
    }
    if ((h>336) && (h<=357)) {
      return 335;
    }

    break;
  }
  return 0;
}
