/*This is the code for the Base Station.
  The Base station has 8 VL53L1X ToF sensors.
  The code outputs data in the following format:
  0 MM 1 MM 2 MM 3 MM 4 MM 5 MM 6 MM 7 MM

  where "MM"s are the range readings in units of mm.

  Please put additional attention into the fact that we send the
  data wirelessly using Serial1.print() (NOT Serial.print()) as it is required
  when using the new Nano 33 IoT boards (regular Serial.print() is for cable only)
*/
#include <Wire.h>
#include <VL53L1X.h>
#define INTERRUPT_PIN 2

//The following may be uncommented for other microcontroller than the Nano 33 IoT.
extern "C" {
  //#include "utility/twi.h"  // from Wire library, so we can do bus scanning
}

#define TCAADDR 0x70
#define NUM_SENSORS 8

//Checks if the multiplexer recognises all of the ToF sensors.
void tcaselect(uint8_t i) {
  if (i > 7) return;

  Wire.beginTransmission(TCAADDR);
  Wire.write(1 << i);
  int result = Wire.endTransmission();
}

typedef VL53L1X* VL53L1XPtr;
VL53L1XPtr sensors[NUM_SENSORS];

int floating = 5; //how many past values to take into account for rolling average
int data_points = 8; //the number of unique values to send (equivalent to NUM_SENSORS)
float **averages;
int location = 0;

int deviceID = 8;

void setup()
{
  //Tinkering with the predefined baud rate of 9600 may cause problems, since
  //the HC06 Bluetooth modules can cause transmission errors
  Serial1.begin(9600);

  Wire.begin();
  Wire.setClock(400000); // use 400 kHz I2C

  //Initiating ToF sensors using the multiplexer that allows multiple I2C connections
  for (uint8_t i = 0; i < NUM_SENSORS; i++)
  {
    //We select a specific memory address from the multiplexer to access one of the 8 ToF sensors
    tcaselect(i);

    VL53L1XPtr sensor = new VL53L1X();
    sensor->init();
    if (!sensor->init())
    {
      Serial1.println("Failed to detect and initialize sensor!");
      while (1);
    }

    // Use long distance mode and allow up to 50000 us (50 ms) for a measurement.
    // You can change these settings to adjust the performance of the sensor, but
    // the minimum timing budget is 20 ms for short distance mode and 33 ms for
    // medium and long distance modes. See the VL53L1X datasheet for more
    // information on range and timing limits.

    sensor->setTimeout(100);
    sensor->setDistanceMode(VL53L1X::Long);
    sensor->setMeasurementTimingBudget(50000);

    // Start continuous readings at a rate of one measurement every 50 ms (the
    // inter-measurement period). This period should be at least as long as the
    // timing budget.

    sensor->startContinuous(50);
    sensors[i] = sensor;


  }

  //Before we can start sending the data, we have to make sure the connection is established.
  //Prior this, the Arduino just outputs its ID number.
  establishContact();

  //Allocating space for rolling average calculations for 8 sensors.
  //Rolling average helps us to maintain smoother transitions for one data point
  //to another and reduce twitchiness when visualising data.
  averages = (float**) malloc(sizeof(float*) * 8);
  for (int i = 0; i < data_points; i++) {
    *(averages + i) = (float*) malloc(sizeof(float) * floating);
  }

}

void loop()
{
  if (Serial1.available() > 0) {

    digitalWrite(LED_BUILTIN, HIGH);
    while (Serial1.read() != -1) {}

    for (uint8_t i = 0; i < NUM_SENSORS; i++)
    {
      //selects the memory address for the ToF sensor
      tcaselect(i);

      //Activates the sensor.
      VL53L1XPtr sensor = sensors[i];

      //Prints out the sensor's ID
      Serial1.print(i);
      Serial1.print("\t");

      if (sensor->last_status == 0)
      {

        //Outputs the sensors value after calculating its rolling average.
        Serial1.print( floating_average(*(averages + i), location, float(sensor->read())));
        Serial1.print("\t");

        //Moving the number of values in memory for
        //the rolling average
        location += 1;
        if (location >= floating) {
          location = 0;
        }

      } else {
        Serial1.print(sensor->last_status);
      }

    }
    Serial1.println();
    digitalWrite(LED_BUILTIN, LOW);

  } else {
    digitalWrite(LED_BUILTIN, LOW);
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

void establishContact() {
  digitalWrite(LED_BUILTIN, HIGH);
  
  while (Serial1.available() <= 0) {
    digitalWrite(LED_BUILTIN, LOW);
    Serial1.println(char(deviceID));
    delay(300);
  }
}
