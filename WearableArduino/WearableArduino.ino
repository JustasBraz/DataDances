/*This is the code for the Wearables.
  The Wearables have HC06 Bluetooth modules
  and Arduino Nano 33 IoT microcontrollers built into them.

  The code outputs data in the following format:
  X MMM MMM MMM

  where "X" is the device ID and the "MMM"s are the readings
  provided by the IMU installed on the Nanos.

  Please put additional attention into the fact that we send the
  data wirelessly using Serial1.print() (NOT Serial.print()) as it is required
  when using the new Nano 33 IoT boards (regular Serial.print() is for cable only).
*/

#include "SparkFunLSM6DS3.h"
#include "Wire.h"

LSM6DS3 myIMU( I2C_MODE, 0x6A );

int floating = 5; //how many past values to take into account for rolling average
int data_points = 3; //the number of separate readings we send (we send XYZ, so 3)
float **averages;
int location = 0;

int deviceID = 6;

void setup()
{
  pinMode(LED_BUILTIN, HIGH);

  //Tinkering with the predefined baud rate of 9600 may cause problems, since
  //the HC06 Bluetooth modules can cause transmission errors
  Serial1.begin(9600);
  Serial1.setTimeout(50);

  while (!Serial1) {}

  //Initiating the IMU
  if ( myIMU.begin() != 0 ) {
    Serial1.println("Device error");

  } else {
    Serial1.println("Device OK!");
  }

  //Before we can start sending the data, we have to make sure the connection is established.
  //Prior this, the Arduino just outputs its ID number.
  establishContact();

  //Allocating space for rolling average calculations for 3 IMU values (XYZ).
  //Rolling average helps us to maintain smoother transitions for one data point
  //to another and reduce twitchiness when visualising data.
  averages = (float**) malloc(sizeof(float*) * 3);
  for (int i = 0; i < data_points; i++) {
    *(averages + i) = (float*) malloc(sizeof(float) * floating);
  }
}

void loop()
{
  if (Serial1.available() > 0) {

    digitalWrite(LED_BUILTIN, HIGH);
    while (Serial1.read() != -1) {}

    //Sending the IMU values in the following format: X MMM MMM MMM
    //averages + 0 (or +1 or +2) activates one of the three rolling average arrays used
    //to smooth out the readings
    
    Serial1.print(deviceID);
    Serial1.print("\t");
    Serial1.print(floating_average(*(averages + 0), location, myIMU.readFloatAccelX() - 0.03), 3); //- 0.03 is used for calibration
    Serial1.print("\t");
    Serial1.print(floating_average(*(averages + 1), location, myIMU.readFloatAccelY() - 0.03), 3); //- 0.03 is used for calibration
    Serial1.print("\t");
    Serial1.println(floating_average(*(averages + 2), location, myIMU.readFloatAccelZ() - 1.0), 3); //- 1.0 is used for calibration

    //Moving the number of values in memory for
    //the rolling average
    location += 1;
    if (location >= floating) {
      location = 0;
    }

    digitalWrite(LED_BUILTIN, LOW);

  } else {
    digitalWrite(LED_BUILTIN, LOW);
  }


}

void establishContact() {
  digitalWrite(LED_BUILTIN, HIGH);
  while (Serial1.available() <= 0) {
    digitalWrite(LED_BUILTIN, LOW);
    Serial1.println(char(deviceID));
    delay(300);
  }
}

float floating_average(float* array, int loc, float val) {
  *(array + loc) = val;
  float avg = 0;
  for (int i = 0; i < floating; i++) {
    avg += *(array + i);
  }
  return (avg / floating);
}
