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

float [] inputs =new float [8];//={Pos1, Pos2, Pos3, Pos4, Pos5, Pos6, Pos7, Pos8};
int [] offsetAngles={135, 180, 225, 270, 315, 360, 45, 90};

float simulateStep=0;

int mode=-1;
int visualAid=-1;

float increment=0;
boolean swing;

String session;

boolean SIMULATION= true;
boolean RECORDING=false;
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

  if (!SIMULATION) {
    attemptConnection("COM4", 9600);
  }
  //The folder to save screen-captured images
  session="test2/";

  soundSetup();

  //Setting up GUI and the spacing between buttons
  initGUI();

  //Initiating the array that will keep the 8 sensor values and 
  //transform them into XY coordinates
  //for (int i =0; i<8; i++) {
  //  Dots.add(new Dot(0, 0, i));
  Dots.add(new Dot (new PVector(0, 1), 1));
  Dots.add(new Dot (new PVector(cos(radians(135)), sin(radians(135))), 2));
  Dots.add(new Dot (new PVector(-1, 0), 3));
  Dots.add(new Dot (new PVector(cos(radians(225)), sin(radians(225))), 4));
  Dots.add(new Dot (new PVector(0, -1), 5));
  Dots.add(new Dot (new PVector(cos(radians(315)), sin(radians(315))), 6));
  Dots.add(new Dot (new PVector(1, 0), 7));
  Dots.add(new Dot (new PVector(cos(radians(45)), sin(radians(45))), 8));
  //}

  println("Entering draw");
  delay(1000);
}

void draw()
{ 
  //IF USING THE ACTUAL BASE STATION, LEAVE UNCOMMENTED
  //otherwise, to conduct tests in simulated mode, comment
  //the following line out: 
  if (SIMULATION) {
    simulateData();
  } else {
    maintainConnections();
  }
  //and uncomment the following line:

  background(255);
  translate(width/2, height/2);

  processKeys();
  GUI("Regular");

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
    background(0);
    ac.stop();
    binaryMode();
    GUI("inverse");

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

  if (RECORDING) {
    record();
  }
} 
void attemptConnection(String COM, int baud) {
  Port_1 = new Serial(this, COM, baud); //9600 as it must match the baud rate on the Arduinos
  Port_1.bufferUntil(13); //13 is the ASCII linefeed value
}
//Function displays end point coordinates
void drawDots() {
  for (Dot d : Dots) {
    d.display();
  }
}
void maintainConnections() {
  Port_1.write('0');
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
void record() {
  if (frameCount%29==0) {
    saveFrame(session+frameCount+".jpg");
  }
}
void initGUI() {
  int spacing=10;
  for (int i=0; i<8; i++) {
    Buttons.add(new Button(-width/2+50, -height/2+(i*50+50)+spacing, i));
    spacing+=20;
  }
}

void GUI(String colorMode) {
  textSize(18);
  for (Button b : Buttons ) {

    if (b.activate(colorMode)&&mousePressed) {
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


  for (int i =0; i<8; i++) {
    Dots.get(i).setPos(inputs[i]);
    Dots.get(i).checkBinaryThreshold();
    Dots.get(i).displayState();
    line(0, 0, Dots.get(i).getPos().x, Dots.get(i).getPos().y);
  }
  displayBinaryStates();
  stroke(0);
  strokeWeight(1);
}

void displayBinaryStates() {
  String [] states = new String [8];
  String [] IDs = new String [8];
  for (int i =0; i<8; i++) {
    //binaryStates=replaceCharAt(binaryStates, i, char(Dots.get(i).state));
    states[i]=  str(Dots.get(i).state);
    IDs[i]=str(Dots.get(i).name);
  }
  String binaryStates= join(states, " ");
  String binaryStatesRaw=join(states, "");
  String dotIDs= join(IDs, " ");

  //println(unbinary(binaryStatesRaw));
  fill(255);
  textSize(90);
  text(unbinary(binaryStatesRaw), 70, 400);
  textSize(25);
  text(binaryStates, 300, 350);
  fill(255, 50);
  text(dotIDs, 300, 400);
}
//https://forum.processing.org/one/topic/replacing-a-single-specific-character-in-a-string.html
String replaceCharAt(String s, int pos, char c) {
  StringBuilder sb = new StringBuilder(s); //or StringBuffer
  sb.setCharAt(pos, c);
  return sb.toString();
}
void flowerMode() {

  fill(0, 0, 150);

  beginShape();
  stroke(filler, alpha);
  int next;
  for (int i =0; i<8; i++) {
    if (i==7) {
      next=0;
    } else next=i+1;

    //println(inputs[i]);
    Dots.get(i).setPos(inputs[i]);
    vertex(Dots.get(i).getPos().x, Dots.get(i).getPos().y);
    vertexFiller(offsetAngles[i], inputs[i], inputs[next], 1);
  }
  vertex(0, Pos1);

  endShape();
}
void radarMode() {

  fill(0, 150, 0);

  beginShape();
  stroke(filler, alpha);

  int next;
  for (int i =0; i<8; i++) {
    if (i==7) {
      next=0;
    } else next=i+1;

    //println(inputs[i]);
    Dots.get(i).setPos(inputs[i]);
    vertex(Dots.get(i).getPos().x, Dots.get(i).getPos().y);
    vertexFiller(offsetAngles[i], inputs[i], inputs[next], 2);
  }


  vertex(0, Pos1);

  endShape();
}
void sharpMode() {

  fill(150, 0, 0);

  beginShape();
  stroke(filler, alpha);

  for (int i =0; i<8; i++) {
    //println(inputs[i]);
    Dots.get(i).setPos(inputs[i]);
    vertex(Dots.get(i).getPos().x, Dots.get(i).getPos().y);
  }


  vertex(0, Pos1);

  endShape();
}
void curvedMode() {

  fill(150, 150, 0);

  beginShape();
  stroke(filler, alpha);

  curveVertex(Dots.get(0).getPos().x, Dots.get(0).getPos().y);

  for (int i =0; i<8; i++) {

    //println(inputs[i]);
    Dots.get(i).setPos(inputs[i]);
    curveVertex(Dots.get(i).getPos().x, Dots.get(i).getPos().y);
  }

  curveVertex(Dots.get(7).getPos().x, Dots.get(7).getPos().y); 

  endShape();

  //Due to a bug where Processing can't close shapes,
  //we create a new shape that will be superimposed 
  //on the first one
  beginShape();

  curveVertex(Dots.get(6).getPos().x, Dots.get(6).getPos().y);
  curveVertex(Dots.get(7).getPos().x, Dots.get(7).getPos().y); 
  curveVertex(Dots.get(0).getPos().x, Dots.get(0).getPos().y);
  curveVertex(Dots.get(1).getPos().x, Dots.get(1).getPos().y);

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

  inputs[0]=Pos1;
  inputs[1]=Pos2;
  inputs[2]=Pos3;
  inputs[3]=Pos4;
  inputs[4]=Pos5;
  inputs[5]=Pos6;
  inputs[6]=Pos7;
  inputs[7]=Pos8;
  //inputs =[Pos1, Pos2, Pos3, Pos4, Pos5, Pos6, Pos7, Pos8];
}

//The following function extrapolates the curve betwen two sensor rays and 
//enables us to create curved edges usually beyond what curveVertex() can offer
void vertexFiller(int degree, float ray1, float ray2, int mode) {
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

        inputs[0]=Pos1;
        inputs[1]=Pos2;
        inputs[2]=Pos3;
        inputs[3]=Pos4;
        inputs[4]=Pos5;
        inputs[5]=Pos6;
        inputs[6]=Pos7;
        inputs[7]=Pos8;
      }
    }
  }
  catch(Exception e) {
    println("Error parsing:");
    e.printStackTrace();
  }
}
