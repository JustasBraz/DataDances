//This code is used to visualise the base station output on screen. //<>//
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
float Pos1, Pos2, Pos3, Pos4, Pos5, Pos6, Pos7, Pos8 = 0;

color filler = color(0, 76, 153);
int alpha = 100;

HashSet < Character > keysDown;
ArrayList < Dot > Dots;
ArrayList < Button > Buttons;

//Declaring values for simulation mode
float[] sim_init = new float[8];

float[] inputs = new float[8]; //={Pos1, Pos2, Pos3, Pos4, Pos5, Pos6, Pos7, Pos8};
int[] offsetAngles = {135, 180, 225, 270, 315, 360, 45, 90};

float simulateStep = 0;

int mode = -1;
int visualAid = -1;

float increment = 0;
boolean swing;

String session;

boolean SIMULATION = true;
boolean RECORDING = false;
void setup() {
  keysDown = new HashSet < Character > ();
  Dots = new ArrayList < Dot > ();
  Buttons = new ArrayList < Button > ();

  //Frame rate should be left at 40 as it helps avoid lag from 
  //constant handshaking with the Arduino
  frameRate(40);

  size(1000, 1000);
  //fullScreen();

  printArray(Serial.list()); //displays all available ports; quite useful for debugging.

  //IF USING THE ACTUAL BASE STATION, LEAVE UNCOMMENTED
  //otherwise, to conduct tests in simulated mode, set SIMULATION to true

  if (!SIMULATION) {
    attemptConnection("COM4", 9600);
  } else {
    for (int i = 0; i < 8; i++) {
      sim_init[i] = random(0, 20000);
    }
  }
  //The folder to save screen-captured images
  session = "test2/";

  soundSetup();

  //Setting up GUI and the spacing between buttons
  initGUI();

  //Initiating the array that will keep the 8 sensor values and 
  //transform them into XY coordinates
  for (int i = 1; i < 8; i++) {
    Dots.add(new Dot(new PVector(cos(radians(45 + 45 * i)), sin(radians(45 + 45 * i))), i));
  }
  Dots.add(new Dot(new PVector(cos(radians(45)), sin(radians(45))), 8)); // Special Case

  println("Entering draw");
  delay(1000);
}

void draw() {
  if (SIMULATION) {
    simulateData();
  } else {
    maintainConnections();
  }

  background(255);
  translate(width / 2, height / 2);

  processKeys();
  GUI("Regular");

  //Selects the active mode (activated but the buttons on screen):
  switch (mode) {

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
      background(0);
      ac.stop();
      spellingMode();
      GUI("inverse");
      break;
    case 6:
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
    case 7:
      drawDots();
      break;
    case 8:
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
  for (Dot d: Dots) {
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

  for (Dot d: Dots) {

    allTrue = allTrue && d.matchingEllipse();
  }
  if (allTrue) {
    background(0, 255, 0);
  }
  drawEllipse();
  fill(0, 102, 153, 10);
}
void record() {
  if (frameCount % 29 == 0) {
    saveFrame(session + frameCount + ".jpg");
  }
}
void initGUI() {
  int spacing = 10;
  for (int i = 0; i < 9; i++) {
    Buttons.add(new Button(-width / 2 + 50, -height / 2 + (i * 50 + 50) + spacing, i));
    spacing += 20;
  }
}

void GUI(String colorMode) {
  textSize(18);
  for (Button b: Buttons) {

    if (b.activate(colorMode) && mousePressed) {
      mode = b.getMode();
      visualAid = b.getMode();
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
  PVector[] lerps = new PVector[9];
  float initPos = 0.1;
  PVector start = new PVector(xStart, yStart);
  PVector fin = new PVector(xFin + sin(step) * 25, yFin + sin(step) * 25);
  for (int i = 0; i < lerps.length; i++) {
    lerps[i] = PVector.lerp(start, fin, initPos);
    initPos += 0.1;
  }

  beginShape();
  vertex(xStart, yStart);

  if (swing) {
    for (int i = 0; i < lerps.length; i++) {
      vertex(lerps[i].x + random(-5, 5) * 2, lerps[i].y + cos(random(-5, 5)) * 2);
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

  for (int i = 0; i < 8; i++) {
    checkOctaveThreshold(inputs[i], i + 1);
    curvyLine(0, 0, cos(radians(90 + 45 * i)) * inputs[i], sin(radians(90 + 45 * i)) * inputs[i], increment);
  }
  stroke(200);
  strokeWeight(1);
  increment += 0.1;
}

void checkOctaveThreshold(float input, int sensor) {
  if (input < 200) {
    swing = true;
    color c = color(random(0, 255), random(0, 255), random(0, 255), 75);
    float sensor_values[] = {0.001f, 0.01f, 0.05f, 0.1f, 0.25f, 0.5f, 0.8f, 1.2f};

    stroke(c);
    strokeWeight(8);
    if (sensor < 1 || sensor > 8) {
      ac.stop();
    } else {
      carrierFreq.setValue(sensor_values[sensor - 1] * 1000 + 50);
    }
  } else {

    swing = false;
    stroke(160);
    strokeWeight(1);
  }
}

void binaryMode() {
  for (int i = 0; i < 8; i++) {
    Dots.get(i).setPos(inputs[i]);
    Dots.get(i).checkBinaryThreshold();
    Dots.get(i).displayState(0, 1);
    line(0, 0, Dots.get(i).getPos().x, Dots.get(i).getPos().y);
  }
  displayBinaryStates();
  stroke(0);
  strokeWeight(1);
}

int spellingModeWordListLength = 10;

String spellingModeWordList[] = {"light", "dog", "cat", "UCLIC", "scarf", "bird", "robin", "sparrow", "cup", "blue jay"};
String spellingModeString = "light";
String spellingModeResult = "lh___";
int spellingModeCur = 2;
long spellingModeDelay = 10 * 1000;
long spellingModeNextTime = System.currentTimeMillis() + spellingModeDelay;

void spellingMode() {
  fill(255);
  textSize(75);
  if (!(spellingModeCur == spellingModeString.length())) {
    char nextChar = spellingModeString.charAt(spellingModeCur);
    text(binary(int(nextChar), 8), 50, -350);
  } else {
    text("Generating", 50, -350);
  }
  for (int i = 0; i < 8; i++) {
    Dots.get(i).setPos(inputs[i]);
    Dots.get(i).checkBinaryThreshold();
    Dots.get(i).displayState(50, 0.8);
    line(0, 50, Dots.get(i).getPos().x, Dots.get(i).getPos().y * 0.8 + 50);
  }
  char curChar = displayBinaryStates();
  

  
  
  int loc = -350;
  for (int i = 0; i < spellingModeString.length(); i++) {
    if (spellingModeResult.charAt(i) == '_') {
      if (i == spellingModeCur) {
        fill(map(System.currentTimeMillis() - spellingModeNextTime + spellingModeDelay, 0, spellingModeDelay, 100, 255));
      } else {
        fill(100);
      }
    } else if (spellingModeResult.charAt(i) == spellingModeString.charAt(i)) {
      fill(0, 255, 0); 
    } else {
      fill(255, 0, 0);
    }
    textSize(75);
    text(spellingModeString.charAt(i), loc, -350);
    float middleLoc = loc += textWidth(spellingModeString.charAt(i)) / 2;
    loc += textWidth(spellingModeString.charAt(i)) + 5;
    
    textSize(20);
    fill(175);
    middleLoc -= textWidth(i==spellingModeCur ? curChar : spellingModeResult.charAt(i)) / 2;
    text(i==spellingModeCur ? curChar : spellingModeResult.charAt(i), middleLoc, -300);    
  }

  
  if (System.currentTimeMillis() > spellingModeNextTime) {
       if (spellingModeCur < spellingModeString.length()) {
         spellingModeResult = replaceCharAt(spellingModeResult, spellingModeCur, curChar);
         spellingModeCur += 1;
       } else {
         //New word
         spellingModeString = spellingModeWordList[int(random(0, spellingModeWordListLength))];
         StringBuilder sb = new StringBuilder();
          for (int i = 0; i < spellingModeString.length(); i++) {
            sb.append('_');
          }
          spellingModeResult = sb.toString();
          spellingModeCur = 0;
       }
      
      
      spellingModeNextTime = System.currentTimeMillis() + (spellingModeCur == spellingModeString.length() ? spellingModeDelay * 2 : spellingModeDelay);
      
    }
  
  stroke(0);  
  strokeWeight(1);
}

HashMap <Integer, Float> rollingAverageHash = new HashMap <Integer, Float> ();

// Rolling Average, for example rollingAverage(0, input[i], 10);
float rollingAverage(int id, float input, float count) {
  float avg = rollingAverageHash.getOrDefault(id, input);
  avg -= avg / count;
  avg += input / count;
  rollingAverageHash.put(id, avg);
  return avg;
}

char displayBinaryStates() {
  String[] states = new String[8];
  String[] IDs = new String[8];
  for (int i = 0; i < 8; i++) {
    //binaryStates=replaceCharAt(binaryStates, i, char(Dots.get(i).state));
    states[i] = str(Dots.get(i).state);
    IDs[i] = str(Dots.get(i).name);
  }
  String binaryStates = join(states, " ");
  String binaryStatesRaw = join(states, "");
  String dotIDs = join(IDs, " ");

  //println(unbinary(binaryStatesRaw));
  fill(255);
  textSize(90);
  text(unbinary(binaryStatesRaw), 70, 400);
  text(char(unbinary(binaryStatesRaw)), -70-90, 400);
  textSize(25);
  text(binaryStates, 300, 350);
  fill(255, 50);
  text(dotIDs, 300, 400);
  return (char(unbinary(binaryStatesRaw)));
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
  for (int i = 0; i < 8; i++) {
    if (i == 7) {
      next = 0;
    } else next = i + 1;

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
  for (int i = 0; i < 8; i++) {
    if (i == 7) {
      next = 0;
    } else next = i + 1;

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

  for (int i = 0; i < 8; i++) {
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
  //first and last vertices get called two times to open and close the shape
  curveVertex(Dots.get(0).getPos().x, Dots.get(0).getPos().y);

  for (int i = 0; i < 8; i++) {

    //println(inputs[i]);
    Dots.get(i).setPos(inputs[i]);
    curveVertex(Dots.get(i).getPos().x, Dots.get(i).getPos().y);
  }

  //first and last vertices get called two times to open and close the shape
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

    for (int i = 0; i < 8; i++) {
      if (key == char(i)) {
        if (i == 7 || i == 8) {
          mode = i;
          break;
        }
        mode = i;
        visualAid = -1;
      }
    }
  }
}

void simulateData() {
  for (int i = 0; i < 8; i++) {
    inputs[i] = map(noise(sim_init[i] + simulateStep), 0, 1, 0, 500);
  }
  simulateStep += 0.012;
}

//The following function extrapolates the curve betwen two sensor rays and 
//enables us to create curved edges usually beyond what curveVertex() can offer
void vertexFiller(int degree, float ray1, float ray2, int mode) {
  float value;
  float step;
  float divisions; // determines the amount of times we want to divide an arc
  //We use two modes, one for the Radar Mode, and another for the Flower Mode
  //Both different in the curvature we are trying to draw
  if (mode == 1) {
    divisions = 0.1;
    for (int condition = 10; condition > 0; condition--) {
      step = 45 / 10;
      value = (1 - divisions) * ray1 + divisions * ray2;
      divisions += 0.1;
      vertex(cos(radians(degree - (condition) * step)) * value, sin(radians(degree - (condition) * step)) * value);
      strokeWeight(0.5);
    }
  }
  if (mode == 2) {
    divisions = 1 / 45;
    for (int condition = 45; condition > -1; condition--) { //45,0
      step = 45 / 44;
      value = (1 - divisions) * ray1 + divisions * ray2;
      vertex(cos(radians(degree - (condition) * step)) * value, sin(radians(degree - (condition) * step)) * value);
      divisions += divisions;
      strokeWeight(0.5);
    }
  }
}


//This function's name should not be modified, as the Serial library is very sensitive
//about how it handles data, and serialEvent() is crucial.
void serialEvent(Serial p) {
  try {
    String message = p.readStringUntil(13); // get message till line break (ASCII > 13)

    if (message != null) {
      print(message);
      message = trim(message);
      String items[] = split(message, '\t');

      //checks that the message has sufficient data points
      if (items.length > 14) {

        int thresh = 500;

        int maxSensorValue = 3500; //has to be tested empircally
        for (int i = 0; i < 8; i++) {
          inputs[i] = map(float(items[2 * i + 1]), 0, maxSensorValue, 0, thresh);
        }
      }
    }
  } catch (Exception e) {
    println("Error parsing:");
    e.printStackTrace();
  }
}
