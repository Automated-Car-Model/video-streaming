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

#### Flutter
* [Flutter_joystick](https://pub.dev/packages/flutter_joystick)
* [quick_blue](https://pub.dev/packages/quick_blue/versions)
* [web_socket_channel](https://pub.dev/packages/web_socket_channel)
  
## Quick start
