//This code is used to visualise the base station output on screen.
//For the sound Beads library has to be installed.

import processing.serial.*;
import java.util.HashSet;
import beads.*;
import java.util.Arrays; 

//Declaring objects used for the sound library
AudioContext ac;
Glide carrierFreq, modFreqRatio;

//Declaring a Serial port object
Serial Port_1;

//Declaring global variables
//8 positional values for each of the sensors
float Pos1, Pos2, Pos3, Pos4, Pos5, Pos6, Pos7, Pos8=0;

color filler=color(0, 76, 153);
int alpha=100;

HashSet<Character> keysDown;
ArrayList<Dot> Dots;
ArrayList<Button> Buttons;

//Declaring values for simulation mode
float init1=random(0, 20000);
float init2=random(0, 20000);
float init3=random(0, 20000);
float init4=random(0, 20000);
float init5=random(0, 20000);
float init6=random(0, 20000);
float init7=random(0, 20000);
float init8=random(0, 20000);
float simulateStep=0;

int mode=-1;
int visualAid=-1;

float increment=0;
boolean swing;

String session;

void setup()
{ 
  keysDown = new HashSet<Character>();
  Dots = new ArrayList<Dot>();
  Buttons = new ArrayList<Button>();

  //Frame rate should be left at 40 as it helps avoid lag from 
  //constant handshaking with the Arduino
  frameRate(40);

  size (1000, 1000);
  //fullScreen();

  printArray(Serial.list());//displays all available ports; quite useful for debugging.

  //IF USING THE ACTUAL BASE STATION, LEAVE UNCOMMENTED
  //otherwise, to conduct tests in simulated mode, comment
  //the following two lines out:  

   Port_1 = new Serial(this, "COM5", 9600); //9600 as it must match the baud rate on the Arduinos
   Port_1.bufferUntil(13); //13 is the ASCII linefeed value 

  //The folder to save screen-captured images
  session="test2/";

  soundSetup();

  //Setting up GUI and the spacing between buttons
  int spacing=10;
  for (int i=0; i<8; i++) {
    Buttons.add(new Button(-width/2+50, -height/2+(i*50+50)+spacing, i));
    spacing+=20;
  }

  //Initiating the array that will keep the 8 sensor values and 
  //transform them into XY coordinates
  for (int i =0; i<8; i++) {
    Dots.add(new Dot(0, 0, i));
  }

  println("Entering draw");
  delay(1000);
}

void draw()
{ 
  //IF USING THE ACTUAL BASE STATION, LEAVE UNCOMMENTED
  //otherwise, to conduct tests in simulated mode, comment
  //the following line out: 

   Port_1.write('0');

  //and uncomment the following line:
  //simulateData();

  background(255);
  translate(width/2, height/2);

  //Selects the active mode (activated but the buttons on screen):
  switch(mode) {

  case 0:
    ac.stop();
    sharpMode();
    break;
  case 1:
    ac.stop();
    flowerMode();
    break;
  case 2:
    ac.stop();
    radarMode();
    break;
  case 3:
    ac.stop();
    curvedMode();
    break;
  case 4:
    ac.stop();
    binaryMode();
    break;
  case 5:
    ac.start();
    octaveMode();
    break;
  default:
    ac.stop();
    radarMode();
    break;
  }

  //In addition to different modes of visualisations
  //there are two visual aids that can be used
  //one displays the end points of sensor values
  //and another initiates the matchingShape minigame
  switch (visualAid) {
  case 6:
    drawDots();
    break;
  case 7:
    matchingShape();
    break;

  default:
    break;
  }

  processKeys();
  GUI();

  //uncomment for saving every 29th frame
  //if (frameCount%29==0) {
  //  saveFrame(session+frameCount+".jpg");
  //}
} 

//Function displays end point coordinates
void drawDots() {
  for (Dot d : Dots) {
    d.display();
  }
}

//draws an ellipse on screen and makes the screen flash if all ent points
//are withing the perimeter of the ellipse
void matchingShape() {
  boolean allTrue = true;

  for (Dot d : Dots) {

    allTrue = allTrue && d.matchingEllipse();
  }
  if (allTrue) {
    background(0, 255, 0);
  }
  drawEllipse();
  fill(0, 102, 153, 10);
}

void GUI() {
  textSize(18);
  for (Button b : Buttons ) {

    if (b.activate()&&mousePressed) {
      mode=b.getMode();
      visualAid=b.getMode();
    }
  }
}

//Initiates the sound library, copied from beads library example #3
void soundSetup() {
  ac = new AudioContext();
  carrierFreq = new Glide(ac, 500);
  modFreqRatio = new Glide(ac, 1);
  Function modFreq = new Function(carrierFreq, modFreqRatio) {
    public float calculate() {
      return x[0] * x[1];
    }
  };
  WavePlayer freqModulator = new WavePlayer(ac, modFreq, Buffer.SINE);
  Function carrierMod = new Function(freqModulator, carrierFreq) {
    public float calculate() {
      return x[0] * 400.0 + x[1];
    }
  };
  WavePlayer wp = new WavePlayer(ac, carrierMod, Buffer.SINE);
  Gain g = new Gain(ac, 1, 0.1);
  g.addInput(wp);
  ac.out.addInput(g);
  ac.start();
  ac.stop();
}

//draws curvy lines to match funky sound effects
void curvyLine(float xStart, float yStart, float xFin, float yFin, float step) {
  PVector [] lerps = new PVector[9];
  float initPos=0.1;
  PVector start = new PVector(xStart, yStart);
  PVector fin = new PVector(xFin+sin(step)*25, yFin+sin(step)*25);
  for (int i =0; i<lerps.length; i++) {
    lerps[i]=PVector.lerp(start, fin, initPos);
    initPos+=0.1;
  }

  beginShape();
  vertex(xStart, yStart);

  if (swing) {
    for (int i =0; i<lerps.length; i++) {

      vertex(lerps[i].x+random(-5, 5)*2, lerps[i].y+cos(random(-5, 5))*2);
    }

    vertex(fin.x, fin.y);
  } else {
    vertex(xFin, yFin);
  }
  endShape();
}

void octaveMode() {
  stroke(160);
  strokeWeight(1);
  checkOctaveThreshold(Pos1, 1);
  curvyLine(0, 0, 0, Pos1, increment);
  checkOctaveThreshold(Pos2, 2);
  curvyLine(0, 0, cos(radians(135))*Pos2, sin(radians(135))*Pos2, increment);
  checkOctaveThreshold(Pos3, 3);
  curvyLine(0, 0, -Pos3, 0, increment);
  checkOctaveThreshold(Pos4, 4);
  curvyLine(0, 0, cos(radians(225))*Pos4, sin(radians(225))*Pos4, increment);
  checkOctaveThreshold(Pos5, 5);
  curvyLine(0, 0, 0, -Pos5, increment);
  checkOctaveThreshold(Pos6, 6);
  curvyLine(0, 0, cos(radians(315))*Pos6, sin(radians(315))*Pos6, increment);
  checkOctaveThreshold(Pos7, 7);
  curvyLine(0, 0, Pos7, 0, increment);
  checkOctaveThreshold(Pos8, 8);
  curvyLine(0, 0, cos(radians(45))*Pos8, sin(radians(45))*Pos8, increment);
  stroke(200);
  strokeWeight(1);
  increment+=0.1;
}

void checkOctaveThreshold(float input, int sensor) {
  if (input<200) {
    swing=true;
    color c =color(random(0, 255), random(0, 255), random(0, 255), 75);
    switch(sensor) {
    case 1:  

      stroke(c);
      strokeWeight(8);
      carrierFreq.setValue((float)0.001 * 1000 + 50);
      break;

    case 2:
      carrierFreq.setValue((float)0.01 * 1000 + 50);
      stroke(c);
      strokeWeight(8);
      break;

    case 3:
      carrierFreq.setValue((float)0.05 * 1000 + 50);
      stroke(c);
      strokeWeight(8);
      break;

    case 4: 
      carrierFreq.setValue((float)0.1 * 1000 + 50);
      stroke(c);
      strokeWeight(8);
      break;

    case 5: 
      carrierFreq.setValue((float)0.25 * 1000 + 50);
      stroke(c);
      strokeWeight(8);
      break;

    case 6: 
      carrierFreq.setValue((float)0.5 * 1000 + 50);
      stroke(c);
      strokeWeight(8);
      break;

    case 7:
      carrierFreq.setValue((float)0.8 * 1000 + 50);
      stroke(c);
      strokeWeight(8);
      break;

    case 8: 
      carrierFreq.setValue((float)1.2 * 000 + 50);
      stroke(c);
      strokeWeight(8); 
      break;

    default:
      ac.stop();
      stroke(c);
      strokeWeight(8);

      break;
    }
  } else { 

    swing=false;
    stroke(160);
    strokeWeight(1);
  }
}

void binaryMode() {
  stroke(160);
  strokeWeight(1);

  checkBinaryThreshold(Pos1);
  line(0, 0, 0, Pos1);

  checkBinaryThreshold(Pos2);
  line(0, 0, cos(radians(135))*Pos2, sin(radians(135))*Pos2);

  checkBinaryThreshold(Pos3);
  line(0, 0, -Pos3, 0);

  checkBinaryThreshold(Pos4);
  line(0, 0, cos(radians(225))*Pos4, sin(radians(225))*Pos4);

  checkBinaryThreshold(Pos5);
  line(0, 0, 0, -Pos5);

  checkBinaryThreshold(Pos6);
  line(0, 0, cos(radians(315))*Pos6, sin(radians(315))*Pos6);

  checkBinaryThreshold(Pos7);
  line(0, 0, Pos7, 0);

  checkBinaryThreshold(Pos8);
  line(0, 0, cos(radians(45))*Pos8, sin(radians(45))*Pos8);

  stroke(200);
  strokeWeight(1);
}

void checkBinaryThreshold(float input) {
  if (input<300) {
    stroke(0);
    strokeWeight(8);
  } else {
    stroke(200);
    strokeWeight(1);
  }
}
void flowerMode() {

  fill(0, 0, 150);

  beginShape();
  stroke(filler, alpha);

  Dots.get(0).setPos(0, Pos1);
  vertex(0, Pos1);
  vertexFiller(135, Pos1, Pos2, 1);

  Dots.get(1).setPos(cos(radians(135))*Pos2, sin(radians(135))*Pos2);
  vertex(cos(radians(135))*Pos2, sin(radians(135))*Pos2);
  vertexFiller(180, Pos2, Pos3, 1);

  Dots.get(2).setPos(-Pos3, 0);
  vertex(-Pos3, 0);
  vertexFiller(225, Pos3, Pos4, 1);

  Dots.get(3).setPos(cos(radians(225))*Pos4, sin(radians(225))*Pos4);
  vertex(cos(radians(225))*Pos4, sin(radians(225))*Pos4);  
  vertexFiller(270, Pos4, Pos5, 1);

  Dots.get(4).setPos(0, -Pos5);
  vertex(0, -Pos5);
  vertexFiller(315, Pos5, Pos6, 1);

  Dots.get(5).setPos(cos(radians(315))*Pos6, sin(radians(315))*Pos6);
  vertex(cos(radians(315))*Pos6, sin(radians(315))*Pos6);
  vertexFiller(360, Pos6, Pos7, 1);

  Dots.get(6).setPos(Pos7, 0);
  vertex(Pos7, 0);
  vertexFiller(45, Pos7, Pos8, 1);


  Dots.get(7).setPos(cos(radians(45))*Pos8, sin(radians(45))*Pos8);
  vertex(cos(radians(45))*Pos8, sin(radians(45))*Pos8);
  vertexFiller(90, Pos8, Pos1, 1);

  vertex(0, Pos1);

  endShape();
}
void radarMode() {

  fill(0, 150, 0);

  beginShape();
  stroke(filler, alpha);

  Dots.get(0).setPos(0, Pos1);
  vertex(0, Pos1);
  vertexFiller(135, Pos1, Pos2, 2);

  Dots.get(1).setPos(cos(radians(135))*Pos2, sin(radians(135))*Pos2);
  vertex(cos(radians(135))*Pos2, sin(radians(135))*Pos2);
  vertexFiller(180, Pos2, Pos3, 2);

  Dots.get(2).setPos(-Pos3, 0);
  vertex(-Pos3, 0);
  vertexFiller(225, Pos3, Pos4, 2);

  Dots.get(3).setPos(cos(radians(225))*Pos4, sin(radians(225))*Pos4);
  vertex(cos(radians(225))*Pos4, sin(radians(225))*Pos4);  
  vertexFiller(270, Pos4, Pos5, 2);

  Dots.get(4).setPos(0, -Pos5);
  vertex(0, -Pos5);
  vertexFiller(315, Pos5, Pos6, 2);

  Dots.get(5).setPos(cos(radians(315))*Pos6, sin(radians(315))*Pos6);
  vertex(cos(radians(315))*Pos6, sin(radians(315))*Pos6);
  vertexFiller(360, Pos6, Pos7, 2);

  Dots.get(6).setPos(Pos7, 0);
  vertex(Pos7, 0);
  vertexFiller(45, Pos7, Pos8, 2);


  Dots.get(7).setPos(cos(radians(45))*Pos8, sin(radians(45))*Pos8);
  vertex(cos(radians(45))*Pos8, sin(radians(45))*Pos8);
  vertexFiller(90, Pos8, Pos1, 2);

  vertex(0, Pos1);

  endShape();
}
void sharpMode() {

  fill(150, 0, 0);

  beginShape();
  stroke(filler, alpha);

  Dots.get(0).setPos(0, Pos1);
  vertex(0, Pos1);

  Dots.get(1).setPos(cos(radians(135))*Pos2, sin(radians(135))*Pos2);
  vertex(cos(radians(135))*Pos2, sin(radians(135))*Pos2);

  Dots.get(2).setPos(-Pos3, 0);
  vertex(-Pos3, 0);

  Dots.get(3).setPos(cos(radians(225))*Pos4, sin(radians(225))*Pos4);
  vertex(cos(radians(225))*Pos4, sin(radians(225))*Pos4);  

  Dots.get(4).setPos(0, -Pos5);
  vertex(0, -Pos5);

  Dots.get(5).setPos(cos(radians(315))*Pos6, sin(radians(315))*Pos6);
  vertex(cos(radians(315))*Pos6, sin(radians(315))*Pos6);

  Dots.get(6).setPos(Pos7, 0);
  vertex(Pos7, 0);

  Dots.get(7).setPos(cos(radians(45))*Pos8, sin(radians(45))*Pos8);
  vertex(cos(radians(45))*Pos8, sin(radians(45))*Pos8);

  vertex(0, Pos1);

  endShape();
}
void curvedMode() {

  fill(150, 150, 0);

  beginShape();
  stroke(filler, alpha);

  Dots.get(0).setPos(0, Pos1);
  curveVertex(0, Pos1);
  curveVertex(0, Pos1);

  Dots.get(1).setPos(cos(radians(135))*Pos2, sin(radians(135))*Pos2);
  curveVertex(cos(radians(135))*Pos2, sin(radians(135))*Pos2);

  Dots.get(2).setPos(-Pos3, 0);
  curveVertex(-Pos3, 0);

  Dots.get(3).setPos(cos(radians(225))*Pos4, sin(radians(225))*Pos4);
  curveVertex(cos(radians(225))*Pos4, sin(radians(225))*Pos4);  

  Dots.get(4).setPos(0, -Pos5);
  curveVertex(0, -Pos5);

  Dots.get(5).setPos(cos(radians(315))*Pos6, sin(radians(315))*Pos6);
  curveVertex(cos(radians(315))*Pos6, sin(radians(315))*Pos6);

  Dots.get(6).setPos(Pos7, 0);
  curveVertex(Pos7, 0);

  Dots.get(7).setPos(cos(radians(45))*Pos8, sin(radians(45))*Pos8);
  curveVertex(cos(radians(45))*Pos8, sin(radians(45))*Pos8); 
  curveVertex(cos(radians(45))*Pos8, sin(radians(45))*Pos8); 

  endShape();

  //Due to a bug where Processing can't close shapes,
  //we create a new shape that will be superimposed 
  //on the first one
  beginShape();

  curveVertex(Pos7, 0);
  curveVertex(cos(radians(45))*Pos8, sin(radians(45))*Pos8); 
  curveVertex(0, Pos1);
  curveVertex(cos(radians(135))*Pos2, sin(radians(135))*Pos2);

  endShape();
}
void drawEllipse() {
  fill(255, 0, 0, 50);
  ellipse(0, 0, 500, 500);
}
void drawRectangle() {
  fill(255, 0, 0);
  rectMode(CENTER);
  rect(0, 0, 500, 500);
}

void keyPressed() {
  keysDown.add(new Character(key));
}

void keyReleased() {
  keysDown.remove(new Character(key));
}

void processKeys() {
  //to help display boundaries 
  //of rudimentary shapes
  if (keysDown.contains('z')) {
    drawRectangle();
  }

  if (keysDown.contains('x')) {
    drawEllipse();
  }
  
  //changes the mode of display
  if (keyPressed) {    
    switch(key) {

    case '0':
      mode =0;
      visualAid=-1;
      break;
    case '1':
      mode =1;
      visualAid=-1;
      break;
    case '2':
      mode =2;
      visualAid=-1;
      break;
    case '3':
      mode =3;
      visualAid=-1;
      break;
    case '4':
      mode =4;
      visualAid=-1;
      break;
    case '5':
      mode=5;
      visualAid=-1;
      break;
    case '6':
      visualAid=6;
      break;
    case '7':
      visualAid=7;
      break;
    default:
      break;
    }
  }
}

void modeButtons() {

  fill(230);
  ellipse(-width/2+50, -height/2+110, 50, 50);
  ellipse(-width/2+50, -height/2+170, 50, 50);
  ellipse(-width/2+50, -height/2+230, 50, 50);
  noFill();
}
void simulateData() {
  Pos1=map(noise(init1+simulateStep), 0, 1, 0, 500);
  Pos2=map(noise(init2+simulateStep), 0, 1, 0, 500);
  Pos3=map(noise(init3+simulateStep), 0, 1, 0, 500);
  Pos4=map(noise(init4+simulateStep), 0, 1, 0, 500);
  Pos5=map(noise(init5+simulateStep), 0, 1, 0, 500);
  Pos6=map(noise(init6+simulateStep), 0, 1, 0, 500);
  Pos7=map(noise(init7+simulateStep), 0, 1, 0, 500);
  Pos8=map(noise(init8+simulateStep), 0, 1, 0, 500);
  //println(Pos1);
  simulateStep+=0.012;
}

//The following function extrapolates the curve betwen two sensor rays and 
//enables us to create curved edges usually beyond what curveVertex() can offer
void vertexFiller(float degree, float ray1, float ray2, int mode) {
  float value;
  float step;
  float divisions; // determines the amount of times we want to divide an arc
  //We use two modes, one for the Radar Mode, and another for the Flower Mode
  //Both different in the curvature we are trying to draw
  if (mode==1) {
    divisions=0.1;
    for (int condition=10; condition>0; condition--) {
      step=45/10;
      value=(1-divisions)*ray1+divisions*ray2;
      divisions+=0.1;  
      vertex(cos(radians(degree-(condition)*step))*value, sin(radians(degree-(condition)*step))*value);
      strokeWeight(0.5);
    }
  }
  if (mode==2) {
    divisions=1/45;
    for (int condition=45; condition>-1; condition--) {//45,0
      step=45/44;
      value=(1-divisions)*ray1+divisions*ray2;
      vertex(cos(radians(degree-(condition)*step))*value, sin(radians(degree-(condition)*step))*value);
      divisions+=divisions;  
      strokeWeight(0.5);
    }
  }
}


//This function's name should not be modified, as the Serial library is very sensitive
//about how it handles data, and serialEvent() is crucial.
void serialEvent(Serial p) {
  try {
    String message = p.readStringUntil(13);// get message till line break (ASCII > 13)

    if (message != null) {
      message = trim(message);
      String items[] = split(message, '\t');

      //checks that the message has sufficient data points
      if (items.length>3) {

        int thresh=500;

        int maxSensorValue=3500;//has to be tested empircally

        Pos1 = map(float(items[1]), 0, maxSensorValue, 0, thresh);
        Pos2 = map(float(items[3]), 0, maxSensorValue, 0, thresh);
        Pos3 = map(float(items[5]), 0, maxSensorValue, 0, thresh);
        Pos4 = map(float(items[7]), 0, maxSensorValue, 0, thresh);
        Pos5 = map(float(items[9]), 0, maxSensorValue, 0, thresh);
        Pos6 = map(float(items[11]), 0, maxSensorValue, 0, thresh);
        Pos7 = map(float(items[13]), 0, maxSensorValue, 0, thresh);
        Pos8 = map(float(items[15]), 0, maxSensorValue, 0, thresh);
      }
    }
  }
  catch(Exception e) {
    println("Error parsing:");
    e.printStackTrace();
  }
}
