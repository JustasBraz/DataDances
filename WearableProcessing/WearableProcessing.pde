//This code is used to visualise the Wearables on screen.
//Here the processing serial library will be used with multiple serial connections open at once
//Since this has caused issues in the past, more information can be found in the link below:

//https://github.com/processing/processing/blob/master/java/libraries/serial/examples/SerialMultiple/SerialMultiple.pde#L48

import processing.serial.*;

//DECLARING THE NUMBER OF USERS
int No_Users = 2;
//A LIST OF CONNECTED PORTS ON THE PC (UNIQUE FOR EACH MACHINE)
String [] verifiedPorts={"COM7", "COM8"};


String session="test7/";

User[] users;
Serial [] myPorts;

String []  dataIn;      // a list to hold data from the serial ports  

int matching=10;
int activeUsers=0;

void setup()
{ 
  size (1000, 1000);
  //fullScreen();

  background(255);

  //Frame rate should be left at 40 as it helps avoid lag from 
  //constant handshaking with the Arduino
  frameRate(40);

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

  println("Entering draw");
}

void draw()
{ 
  //Implementing handshakes for data packages
  maintainConnections();

  //create a fading background
  translate(width/2, height/2);
  fill(255, 1);
  strokeWeight(0);
  rect(-width/2, -height/2, width, height);
  //if space is pressed, clean the canvas
  cleanCanvas();
  //iterating over the array of users:
  for (int userID=0; userID<No_Users; userID++) {
    //first we pass the data from the serial connection
    //to the User object to convert it to floating point values
    users[userID].putData(dataIn[userID]);
    //Then we visualise it by drawing circles
    //in the appropriate coordinates
    users[userID].move();
  }

  //uncomment for saving every 29th frame
  //if (frameCount%29==0) {
  //  saveFrame(session+frameCount+".jpg");
  //}
} 


//The connection is maintained by constant handshaking
//between the Arduinos and the PC
void maintainConnections() {
  //everytime we send something back to the Arduino,
  //we receive an immediate response with the data.
  //This helps to drastically cut the latency,
  //as just sending the data without any handshakes
  //would cause an overflow and make visualisations
  //much slower.
  for (Serial ports : myPorts) {
    ports.write("0");
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
void cleanCanvas() {

  if (keyPressed) {
    if (key == ' ') {
      background(255);
    }
  }
}
