import java.util.Iterator;

class User { 
  int initial_color;
  int alpha;
  float scale=200;
  //Most probable reason for multi agent radii bug :
  //the following has to be put in User() and made private.
  int deleteAfter = 3000; //Delete stroke after x milliseconds
  float radius=30;

  float yaw, pitch, roll=0;
  float prev_yaw, prev_pitch=0;
  float py, pp=0;
  String identification;

  float dist;
  int unique_color= int(random(0, 255));//unique color for each device

  int numReadings = 12;//the length of the rolling average array

  float[] readings_X = new float[numReadings];   // the readings from the analog input
  int readIndex_X = 0;              // the index of the current reading
  float total_X = 0;                  // the running total
  float average_X = 0;                // the average

  //may have to be put in User(){} and made private
  float STEP_SIZE=0.05;
  float h=0;

  int lastPressedHigh=0;
  int lastPressedLow=0;

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
  void move(String pen) {    
    if (pen.equals("Point")) {
      old_moves.add(new AgeObject(new StrokeObject(initial_color, unique_color, radius, alpha, radius, yaw*scale, pitch*scale, yaw*scale, pitch*scale)));
      
    }
    if (pen.equals("Line")) {
      old_moves.add(new AgeObject(new StrokeObject(initial_color, unique_color, radius, 255, radius, py, pp, yaw*scale, pitch*scale)));    
      pp=pitch*scale;
      py=yaw*scale;
    }
    findDelta(yaw*scale, pitch*scale) ;
    
    Iterator<AgeObject> oldMovesIterator = old_moves.iterator();
      
      while (oldMovesIterator.hasNext()) {
        AgeObject obj = oldMovesIterator.next();
        if (obj.age() > deleteAfter) {
          oldMovesIterator.remove();
        } else {
          obj.stroke.draw(pen);
        } 
      }
  }
  
  ArrayList<AgeObject> old_moves = new ArrayList<AgeObject>();
  
  //visualises the data into circles on screen
  void move(int RGB_bits, String pen) {
    if (pen.equals("Point")) {
      old_moves.add(new AgeObject(new StrokeObject(getRainbow(RGB_bits), 360, 360, alpha, 30, yaw*scale, pitch*scale, yaw*scale, pitch*scale)));
      
    }
    if (pen.equals("Line")) {
      old_moves.add(new AgeObject(new StrokeObject(getRainbow(RGB_bits), 360, 360, 255, 20, py, pp, yaw*scale, pitch*scale)));    
      pp=pitch*scale;
      py=yaw*scale;
    }
    Iterator<AgeObject> oldMovesIterator = old_moves.iterator();
      
      while (oldMovesIterator.hasNext()) {
        AgeObject obj = oldMovesIterator.next();
        if (obj.age() > deleteAfter) {
          oldMovesIterator.remove();
        } else {
          obj.stroke.draw(pen);
        } 
      }
  }
  
  class StrokeObject {
    float v1, v2, v3, alpha, weight, py, px, y, x;
    StrokeObject(float v1, float v2, float v3, float alpha, float weight, float px, float py, float x, float y) {
      this.v1 = v1;
      this.v2 = v2;
      this.v3 = v3;
      this.alpha = alpha;
      this.weight = weight;
      this.px = px;
      this.py = py;
      this.x = x;
      this.y = y;
    }
    void draw(String pen) {
      stroke(v1, v2, v3, alpha);
      strokeWeight(weight);
      if (pen.equals("Point")) {
        point(px, py);
      } else {
        line(px, py, x, y);
      }
      
    }
  }
  
  class AgeObject {
     int startTime;
     StrokeObject stroke;
     AgeObject(StrokeObject stroke) {
       this.startTime = millis();
       this.stroke = stroke;
     }
     AgeObject(int startTime, StrokeObject stroke) {
       this.startTime = startTime;
       this.stroke = stroke;
     }
     int age() {
       return millis() - startTime;
     }
  }
  
  void clear() {
    old_moves = new ArrayList<AgeObject>();
  }


  int getRealRainbow(int bits) {
    if (h > 360) {
      h = 0;
      println(true);
    }
    h += STEP_SIZE;

    //change of colors becomes too slow for large bit values
    if (bits==8) {
      h+=2;
    }

    int step=floor(h);
    float n = pow(2, bits);

    return int((step*360/n)%360);
  }
  
  int stage = 0;
  float prev[] = {255, 0, 0};
  float triggerCounter = 0;
  
  int getRainbow(int bits) {
    if (bits == 1) {
      return getFake1();
    }
    if (bits == 2) {
      return getFake2();
    }
    
    double delta = 255 / Math.pow(2, bits);
    
    int order[] = {2, 1, 0, 1, 2, 1, 0, 1};
    float change[] = {1, 1, -1, -1, -1, 1, 1, -1};
    if (triggerCounter >= 255/delta / Math.pow(2, bits)) {
      prev[order[stage]] += change[stage] * delta;
      triggerCounter = 0;
    } else {
      triggerCounter += 1;
    }
    if (change[stage] == 1 && prev[order[stage]] >= 255) {
      prev[order[stage]] = 255;
      stage += 1;
    }
    else if (change[stage] == -1 && prev[order[stage]] <= 0) {
      prev[order[stage]] = 0;
      stage += 1;
    }
    if (stage == 8) {
      stage = 0;
    }
    colorMode(RGB);
    int hue = int(hue(color(prev[0], prev[1], prev[2])));
    colorMode(HSB);
    return hue;
  }
    
  int fakeLoc = 0;
  int getFake1() {
    triggerCounter += 1;
    if (triggerCounter > 64) {
      triggerCounter = 0;
      if (fakeLoc == 0) {
        fakeLoc = 255;
      } else {
        fakeLoc = 0;
      }
    }
    return fakeLoc;
  }
  
  int getFake2() {
    triggerCounter += 1;
    if (triggerCounter > 32) {
      triggerCounter = 0;
      if (fakeLoc == 0) {
        fakeLoc = 320;
      } else if (fakeLoc == 320) {
         fakeLoc = 270; 
      } else if (fakeLoc == 270) {
         fakeLoc = 220;
      } else {
        fakeLoc = 0;
      }
    }
    return fakeLoc;
  }


  void displayTiles(String res) {

    if (res=="High") {

      for (int i=0; i<colsHighRes; i++) {
        for (int j=0; j<rowsHighRes; j++) {
          //show me them goodies
          highResgrid[i][j].display();
          highResgrid[i][j].checkWearable(yaw*scale, pitch*scale);//checkMouse() for simulation

          if (mouseButton == RIGHT) {
            lastPressedHigh=millis();
          }
          if ((millis()-lastPressedHigh)<3000) {
            println(millis()-lastPressedHigh);
            highResgrid[i][j].displayID();
          }
        }
      }
    }
    if (res=="Low") {

      for (int i=0; i<colsLowRes; i++) {
        for (int j=0; j<rowsLowRes; j++) {
          //show me them goodies
          lowResgrid[i][j].display();
          lowResgrid[i][j].checkWearable(yaw*scale, pitch*scale);

          if (mouseButton == RIGHT) {
            lastPressedLow=millis();
          }
          if (abs(millis()-lastPressedLow)<3000) {
            println(millis()-lastPressedLow);
            lowResgrid[i][j].displayID();
          }
        }
      }
    }
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
  void findDelta(float y, float p) {
    //rolling average checks if the acceleration
    //of the device is changing
    dist=getDist(dist(prev_yaw, prev_pitch, y, p));
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
    prev_yaw=y;
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
      String items[] = split(data, '\t');
      //checks if the length of the message is sufficient
      if (items.length>3) {
        //--- Roll,Pitch in degrees
        pitch = float(items[1]);
        yaw = float(items[2]);
        roll = float(items[3]);
        identification = items[0];
        //typecasted from string to float
      }
    }
  }
}
