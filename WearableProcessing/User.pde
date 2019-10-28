class User { 
  int initial_color;
  int alpha;
  float scale=200;
  float radius=30;

  float yaw, pitch, roll=0;
  float prev_roll, prev_pitch=0;

  String identification;

  float dist;
  int unique_color= int(random(0, 255));//unique color for each device

  int numReadings = 12;//the length of the rolling average array

  float[] readings_X = new float[numReadings];   // the readings from the analog input
  int readIndex_X = 0;              // the index of the current reading
  float total_X = 0;                  // the running total
  float average_X = 0;                // the average

  User( int col, int alpha_val) { 
    initial_color = col;
    alpha=alpha_val;

    //runs  rolling average to check if the user has been
    //moving faster or slower
    for (int thisReading = 0; thisReading < numReadings; thisReading++) {
      readings_X[thisReading] = 0;
    }
  }
  
  //visualises the data into circles on screen
  void move() {
    stroke(initial_color, unique_color, radius, alpha);
    strokeWeight(radius);//radius is dependent on movementt
    findDelta(yaw*scale, pitch*scale) ;
    point(yaw*scale, pitch*scale);
  }

  //rolling average implementation
  float getDist(float x) {
    // subtract the last reading:
    total_X = total_X - readings_X[readIndex_X];
    // read from the sensor:
    readings_X[readIndex_X] = x;
    // add the reading to the total:
    total_X = total_X + readings_X[readIndex_X];
    // advance to the next position in the array:
    readIndex_X = readIndex_X + 1;

    // if we're at the end of the array...
    if (readIndex_X >= numReadings) {
      // ...wrap around to the beginning:
      readIndex_X = 0;
    }

    // calculate the average:
    average_X = total_X / numReadings;
    return average_X;
  }

  //determines if to decrease or increase the size of the circle on screen
  void findDelta(float r, float p) {
    //rolling average checks if the acceleration
    //of the device is changing
    dist=getDist(dist(prev_roll, prev_pitch, r, p));
    //increase
    if (dist>5) {
      radius+=0.5;
    } else {
      //decrease or leave at minimum
      if (radius>10) {
        radius-=2;
      } else {
        radius=10;
      }
    }
    prev_roll=r;
    prev_pitch=p;
  }

  float[] getData() {
    float[] dataOut = new float[3];
    dataOut[0]=yaw;
    dataOut[1]=pitch;
    dataOut[2]=roll;
    return dataOut;
  }

  void putData(String data) {
    //check if data is non-empty string
    if (data != null) {
      data = trim(data);
      String items[] = split(data, '\t');
      //checks if the length of the message is sufficient
      if (items.length>3) {
        //--- Roll,Pitch in degrees
        yaw = float(items[1]);
        pitch = float(items[2]);
        roll = float(items[3]);
        identification = items[0];
        //typecasted from string to float
      }
    }
  }
}
