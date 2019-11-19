//This code is used to visualise the Wearables on screen.
//Here the processing serial library will be used with multiple serial connections open at once
//Since this has caused issues in the past, more information can be found in the link below:

//https://github.com/processing/processing/blob/master/java/libraries/serial/examples/SerialMultiple/SerialMultiple.pde#L48

import processing.serial.*;

//DECLARING THE NUMBER OF USERS
int No_Users=1;
//A LIST OF CONNECTED PORTS ON THE PC (UNIQUE FOR EACH MACHINE)
String [] verifiedPorts={"COM4"};//{"COM11", "COM13", "COM18", "COM20", "COM23", "COM25"};



User[] users;
Serial [] myPorts;

String []  dataIn;      // a list to hold data from the serial ports  

int matching=10;
int activeUsers=0;

ArrayList<Button> Buttons;

int mode=-1;
int NO_BUTTONS=7;

Tile [][] lowResgrid;
Tile [][] highResgrid;

boolean SIMULATION= false;
boolean RECORDING=false;
String session="test11_19/RGB_4bits/";

int colsHighRes;
int rowsHighRes;
int colsLowRes;
int rowsLowRes;

void setup()
{ 
  size (1000, 1000);
  colorMode(HSB, 360, 360, 360);

  //fullScreen();

  background(360);
  smooth();

  //Frame rate should be left at 40 as it helps avoid lag from 
  //constant handshaking with the Arduino
  frameRate(40);

  Buttons = new ArrayList<Button>();

  if (!SIMULATION) {
    attemptConnection();
  }

  initGUI(NO_BUTTONS);
  lowResgrid=initTiles(50);
  highResgrid=initTiles(20);
  colsHighRes=ceil(width/20);
  rowsHighRes=ceil(height/20);
  colsLowRes=ceil(width/50);
  rowsLowRes=ceil(height/50);
  println("Entering draw");
}

void draw()
{ 
  // mode =6;
  //TODO: simulation mode
  maintainConnections();


  if(mode!=0 || mode!=1){
  //create a fading background
  fadingBackground();
  }
  //if space is pressed, clean the canvas
  cleanCanvas();

  //iterating over the array of users:
  for (int userID=0; userID<No_Users; userID++) {
    //first we pass the data from the serial connection
    //to the User object to convert it to floating point values
    users[userID].putData(dataIn[userID]);
    //Then we visualise it by drawing circles
    //in the appropriate coordinates

    switch(mode) {

    case 0:
      //LowRes
      translate(-width/2, -height/2);
      background(0,0,360);
      users[userID].displayTiles("Low");
      translate(width/2, height/2);
      GUI();
      break;
    case 1:
      //HighRes
       translate(-width/2, -height/2);
      background(0,0,360);
      users[userID].displayTiles("High");
      translate(width/2, height/2);
      GUI();
      break;
    case 2:
      //Rainbow1
      translate(0, 0);
      users[userID].move(1, "Line");
      break;
    case 3:
      //Rainbow2
      translate(0,0);
      users[userID].move(2, "Line");
      break;
    case 4:
      //Rainbow3
      users[userID].move(4, "Point");
      break;
    case 5:
      //Rainbow4
      users[userID].move(8, "Line");
      break;
    case 6:
      //FreeFlow
      users[userID].move("Line");
      break;
    case 7:
      //FreeFlow
      users[userID].move("Point");
      break;
    default:
      break;
    }
  }

  processKeys();
  GUI();

  if (RECORDING) {
    record();
  }
} 


void maintainConnections() {
  //The connection is maintained by constant handshaking
  //between the Arduinos and the PC.
  //Everytime we send something back to the Arduino,
  //we receive an immediate response with the data.
  //This helps to drastically cut the latency,
  //as just sending the data without any handshakes
  //would cause an overflow and make visualisations
  //much slower.
  for (Serial ports : myPorts) {
    ports.write("0");
  }
}
void attemptConnection() {

  printArray(Serial.list());//displays all available ports; quite useful for debugging.
  myPorts = new Serial[No_Users];
  users=new User [No_Users];
  dataIn = new String[No_Users]; 

  // opening the ports and waiting for the connections:
  while (activeUsers<No_Users) {

    for (int i=0; i<verifiedPorts.length; i++) {
      print("Attempting: ");
      print(verifiedPorts[i]+"\n");
      //try every single port on the list until we get the required number of devices connected
      try {
        myPorts[activeUsers]= new Serial(this, verifiedPorts[i], 9600); //9600 as it must match the baud rate on the Arduinos
        users[activeUsers]=new User(int(random(0, 255)), 50);
        activeUsers++;
        println("Success!");
        println("Awaiting connections: "+activeUsers+"/"+No_Users);
      }
      catch (Exception e) {
        println("Available connections: "+activeUsers+"/"+No_Users);
      }
      if (activeUsers==No_Users) {
        break;
      }
    }
  }

  for (Serial ports : myPorts) {
    ports.bufferUntil(13); //13 is the ASCII linefeed value
  }
}
void record() {
  if (frameCount%13==0) {
    saveFrame(session+frameCount+".jpg");
  }
}
//This function's name should not be modified, as the Serial library is very sensitive
//about how it handles data, and serialEvent() is crucial.
void serialEvent(Serial thisPort) {
  // variable to hold the number of the port:
  int portNumber = -1;

  // iterate over the list of ports opened, and match the 
  // one that generated this event:
  for (int p = 0; p < myPorts.length; p++) {
    if (thisPort == myPorts[p]) {
      portNumber = p;
    }
  }

  // read a message from the port:
  String message = thisPort.readString();
  // put it in the list that holds the latest data from each port:
  if (message != null) {
    dataIn[portNumber] = message;
  }
  //dataIn array then gets sent to be processed in the User object
  //where we cast the serial string data into floats and visualise it
}

void fadingBackground() {
  translate(width/2, height/2);
  fill(255, 1);
  strokeWeight(0);
  rect(-width/2, -height/2, 2*width, 2*height);
}

Tile [][] initTiles(int step) {
  int cols=ceil(width/step);
  int rows=ceil(height/step);
  Tile [][] grid = new Tile[cols][rows];

  //generate grid
  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      //initiate objects
      float nudge=step/2;
      grid[i][j] = new Tile (i*step+nudge, j*step+nudge, step, 0);
    }
  }

  return grid;
}

void cleanCanvas() {

  if (keyPressed) {
    if (key == ' ') {
      background(360);
    }
  }
}

void initGUI(int no_buttons) {
  int spacing=10;
  for (int i=0; i<no_buttons; i++) {
    Buttons.add(new Button(-width/2+50, -height/2+(i*50+50)+spacing, i));
    spacing+=20;
  }
}


void GUI() {
  textSize(18);
  for (Button b : Buttons ) {

    if (b.activate()&&mousePressed) {
      mode=b.getMode();
      background(360);
    }
  }
}

void processKeys() {


  //changes the mode of display
  if (keyPressed) {   
    for (int i =0; i<NO_BUTTONS; i++) {
      if (key==i) {
        mode=i;
      }
    }
  }
}
