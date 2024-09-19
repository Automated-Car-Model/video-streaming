import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:quick_blue/quick_blue.dart';
import 'globals.dart';
import 'dart:async';

const int initialIdleValueSteering = 98;
//current idle steering value
int idleValueSteering = 98;
const int rangeValueSteering = 38;

const int idleValueThrottle = 94;
const int rangeValueThrottle = 80;
//milliseconds beetwen BLE packets
const int timing = 5;

class TraxxasJoystickExample extends StatefulWidget {
  final Globals globals;
  TraxxasJoystickExample({required this.globals}); //required Global variables

  @override
  State<TraxxasJoystickExample> createState() => _TraxxasJoystickExampleState();
}

class _TraxxasJoystickExampleState extends State<TraxxasJoystickExample> {
  int maxValueSteering = idleValueSteering + rangeValueSteering;
  int minValueSteering = idleValueSteering - rangeValueSteering;
  int maxValueThrottle = idleValueThrottle + rangeValueThrottle;
  int minValueThrottle = idleValueThrottle - rangeValueThrottle;

  //range of values for joystick
  double maxValueRange = 1;
  double minValueRange = -1;

  //slider values
  double steeringOffsetSliderValue = 0;
  double powerSliderValue = 0.1;

  //joystick position state
  int stateCommand = 1;

  int steering = idleValueSteering;
  int throttle = idleValueThrottle;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Load configuration variables from SharedPreferences
    loadConfigVariables();
    _timer = Timer.periodic(
        Duration(milliseconds: timing), (Timer t) => _sendData());
    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  //stop timer if page change
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //used to send data command by bluetooth
  void _sendData() {
    List<int> values = [steering, throttle];
    // Convert the list to Uint8List
    Uint8List uint8list = Uint8List.fromList(values);
    //write command value on bluetooth
    QuickBlue.writeValue(
        widget.globals.deviceId,
        widget.globals.bleServiceId,
        widget.globals.movingCharacteristicId,
        uint8list,
        BleOutputProperty.withoutResponse);
  }

  // Retrieve configuration variables from SharedPreferences
  Future<void> loadConfigVariables() async {
    widget.globals.bleServiceId = defaults.bleServiceId;
    widget.globals.movingCharacteristicId = defaults.movingCharacteristicId;
    /* For shared preferences to save the values of the variables when the app is closed and maintained when it is opened again, for now not implemented
    widget.globals.bleServiceId =
        widget.globals.prefs.getString('bleServiceId') ?? defaults.bleServiceId;
    widget.globals.movingCharacteristicId =
        widget.globals.prefs.getString('movingCharacteristicId') ??
            defaults.movingCharacteristicId;
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 180, 87, 21),
      appBar: AppBar(
        title: const Text('Measurify Car'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            Align(
                //joystick steering
                alignment: Alignment(stateCommand * (0.8), 0.5),
                child: Joystick(
                  mode: JoystickMode.horizontal,
                  listener: (details) {
                    setState(() {
                      steering = idleValueSteering +
                          ((details.x * rangeValueSteering).round());
                    });
                  },
                )),
            Align(
                //joystick throttle
                alignment: Alignment(stateCommand * (-0.8), 0.5),
                child: Joystick(
                  mode: JoystickMode.vertical,
                  listener: (details) {
                    setState(() {
                      throttle = idleValueThrottle -
                          ((details.y * rangeValueThrottle * powerSliderValue).round());
                    });
                  },
                )),
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    stateCommand = stateCommand * (-1);
                  });
                },
                child: const Text('Reverse command'),
              ),
            ),
            Positioned(
              top: 20,
              left: 300,
              right: 300,
              child: Column(
                children: [
                  Text("Power percentage"),
                  Text((powerSliderValue * 100).toInt().toString()),
                  Slider(
                    value: powerSliderValue,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        powerSliderValue = value;
                      });
                    },
                  ),
                  Text("Steering Offset"),
                  Text(steeringOffsetSliderValue.toInt().toString()),
                  Slider(
                    value: steeringOffsetSliderValue,
                    min: -10,
                    max: 10,
                    onChanged: (value) {
                      setState(() {
                        steeringOffsetSliderValue = value;
                        idleValueSteering = initialIdleValueSteering +
                            steeringOffsetSliderValue.toInt();
                        //to move wheels
                        steering = idleValueSteering;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
