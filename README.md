# Design and development of an embedded system for video streaming  

## Overview
This project proposes the development and design of an embedded IoT system for a remote-controlled car from the brand Traxxas, operated remotely via a mobile application. The work focused on adding a new feature: the acquisition, transmission, and reception on a mobile device of a video stream showing the vehicle's front view. To achieve this, a camera mounted on an ESP-EYE board, a microcontroller based on an ESP32 chip, was placed on the front fender to provide a real-time view of the road ahead of the car.

The image sequences that make up the video are transmitted by the ESP-EYE via WebSocket over a LAN WiFi network and then received by the mobile device running the application. The app displays the video stream on the screen, with the controls for operating the Traxxas car overlaid on the video. In this way, the user can maneuver the vehicle remotely, taking advantage of the real-time view of the driving environment.

## Hardware and physyical components 
* [ESP-EYE](https://www.espressif.com/en/products/devkits/esp-eye/overview)
* [Arduino Nano 33 BLE Sense](https://store.arduino.cc/products/arduino-nano-33-ble-sense-with-headers?gad_source=1&gclid=CjwKCAjwl6-3BhBWEiwApN6_kigerWUIt1YidLfUCCacnd3wAkLOBn2Lrc0b5pn-Zie1cPfeZbDGAxoCZHIQAvD_BwE) (modified with its own power system)
* [Traxxas car](https://traxxas.com/products/models/electric/58024slash) (modified so that the Arduino can control the vehicle's actuators)
* Mobile device 

## Software 

### Development environments
* [Arduino IDE 2.3.3](https://www.arduino.cc/en/software)
* [Visual Studio Code](https://code.visualstudio.com/) ([Flutter](https://flutter.dev/) framework)

### Libraries
#### Arduino
* [WiFi](https://www.arduino.cc/reference/en/libraries/wifi/)
* [WebSocketsServer](https://www.arduino.cc/reference/en/libraries/websockets/)
  
#### Flutter
* [Flutter_joystick](https://pub.dev/packages/flutter_joystick)
* [quick_blue](https://pub.dev/packages/quick_blue/versions)
* [web_socket_channel](https://pub.dev/packages/web_socket_channel)
  
## Quick start
1. The first step is to download the file [ESP-EYE_code.ino](./Edge/ESP-EYE_code/ESP-EYE_code.ino), and then modify the two constants, ssid and password, related to the WiFi network to which the ESP-EYE will connect and where a WebSocket will be instantiated on the LAN. This part of the code is found in the section related to the initialization of constants:
``` 
#include <WiFi.h>
#include <WebSocketsServer.h>

#include "camera_pins.h"

const char* ssid = "";
const char* password = "";

WebSocketsServer webSocket = WebSocketsServer(81);

void startCameraServer();
```

2. Next, you need to upload the code from the aforementioned file, along with [camera_pins.h](./Edge/ESP-EYE_code/camera_pins.h), to the ESP-EYE board using the Arduino IDE. At this point, a URL should appear on the serial monitor (which contains the internal IP address that the mobile device will need to connect to).
   
3.The mobile app code also needs to be adapted, specifically the file [webcam.dart](./client/traxxas_app/lib/webcam.dart), where the URL mentioned in step 2 must be specified: 
``` 
final channel = WebSocketChannel.connect(
    Uri.parse(
        ''), //insert the URL
  );
```
4. To ensure that the Arduino on board the Traxxas car receives commands via Bluetooth, you need to upload the code from [car-meter.ino](./Edge/car-meter/car-meter.ino).

5. You can now upload the [traxxas_app](./client/traxxas_app) application to the mobile device you want to use to interact with the system. To do this, you can use Flutter within the Visual Studio Code development environment. Both the mobile device and the ESP-EYE must be connected to the same WiFi LAN network so that the mobile device can access the WebSocket instantiated on port 81. It is also possible to use the mobile device's “hotspot” feature, which the ESP-EYE can connect to.

6. Finally, you can use the application: the first interface is dedicated to listing the Bluetooth devices with which a connection can be established. You need to select the Arduino Nano 33 BLE Sense. The second interface manages the actual connection. Lastly, the third screen will present the vehicle controls alongside the video interface.

