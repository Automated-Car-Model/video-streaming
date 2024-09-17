//Library
#include <ArduinoBLE.h>
#include <Servo.h>

//Servo pin
#define STER_OUT 9
#define THR_OUT 10
//servo value
#define MAX_THROTTLE 180
#define IDLE_STEERING 98
#define IDLE_THROTTLE 94
#define MAX_ERROR 100

//Servo object
Servo ster;
Servo thr;

//Command variables
int steering = IDLE_STEERING;
int throttle = IDLE_THROTTLE;
int error=0;
//debugging
bool show_debug_messages=0;     //1 to print messages
unsigned long debug_time = 500;
unsigned long debug_previous=0;
//maximum time to go inside idle state
unsigned long idle_period = 150;
unsigned long idle_previous = 0;

//Define for BLE connection
String name = "Measurify-Car";
const char* service_uuid = "8e7c2dae-0000-4b0d-b516-f525649c49ca";
const char* moving_uuid = "8e7c2dae-0001-4b0d-b516-f525649c49ca";
const char* imu_uuid = "8e7c2dae-0009-4b0d-b516-f525649c49ca";      //used to see service in NRF connect app (not used)
BLEService service(service_uuid);

// IMU: Without this it didn't show correctly the characteristic only write (it's not used)
float acceleration[3];
float angular_speed[3];
float magnetic_field[3];
BLECharacteristic imuCharacteristic(imu_uuid, BLENotify, 9 * sizeof(int16_t)); 

//BLE characteristics
BLECharacteristic movingCharacteristic(moving_uuid,  BLEWrite | BLERead, 2*sizeof(int8_t));

//Write received command on servo
void onMovingCharacteristicWrite(BLEDevice central, BLECharacteristic characteristic);
//degub by print values
void debug();
//BLE initializaton
void init_BLE();

void setup() {
  Serial.begin(9600);
  //servo attach and idle
  ster.attach(STER_OUT);
  thr.attach(THR_OUT);
  ster.write(IDLE_STEERING);
  thr.write(IDLE_THROTTLE);
  //BLE initialization
  init_BLE();  
  delay(1000);
}

void loop() {
  if (BLE.connected()) {
    //show data received from BLE communication
    if(show_debug_messages) {
      debug();
    }
    //idle state if no communication for more than idle_period
    if (millis() -idle_previous >= idle_period) {
      ster.write(IDLE_STEERING);
      thr.write(IDLE_THROTTLE);
      Serial.print("Timeout error ");
      Serial.print(error);
      Serial.println("(idle state)");
      error++;
      //if error overtake max error disconnect BLE and restart advertise
      if(error > MAX_ERROR) {
        BLE.disconnect();
        error=0;
        Serial.println("Looking for new connections");
        BLE.advertise();
      }
      idle_previous = millis();
    }  
  }
  else{
    Serial.println("No BLE client connected...(idle state)");
    ster.write(IDLE_STEERING);
    thr.write(IDLE_THROTTLE);
  }
}

//Write received command on servo
void onMovingCharacteristicWrite(BLEDevice central, BLECharacteristic characteristic){
  //steering
  ster.write(movingCharacteristic[0]);
  //throttle
  thr.write(movingCharacteristic[1]);
  //setting last time received command and reset error
  error=0;
  idle_previous=millis();
}

//debug by print values
void debug(){
  if(millis() - debug_previous >= debug_time){
    Serial.println("Values Changes");
    //steering
    Serial.print("Steering: ");
    Serial.println(movingCharacteristic[0]);
    //throttle
    Serial.print("Throttle: ");
    Serial.println(movingCharacteristic[1]);
    debug_previous=millis();
  }
}

//BLE initializaton
void init_BLE(){
  while(!BLE.begin()) { Serial.println("Error, BLE"); delay(500); };
  String address = BLE.address();
  BLE.setLocalName(name.c_str());
  BLE.setDeviceName(name.c_str());
  BLE.setAdvertisedService(service); 
  service.addCharacteristic(imuCharacteristic);
  service.addCharacteristic(movingCharacteristic);
  movingCharacteristic.setEventHandler(BLEWritten, onMovingCharacteristicWrite);
  BLE.addService(service);
  BLE.advertise();
}