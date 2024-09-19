import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'command.dart';
import 'webcam.dart';

String gssUuid(String code) => '0000$code-0000-1000-8000-00805f9b34fb';

final GSS_SERV__BATTERY = gssUuid('180f');
final GSS_CHAR__BATTERY_LEVEL = gssUuid('2a19');

const WOODEMI_SUFFIX = 'ba5e-f4ee-5ca1-eb1e5e4b1ce0';

const WOODEMI_SERV__COMMAND = '57444d01-$WOODEMI_SUFFIX';
const WOODEMI_CHAR__COMMAND_REQUEST = '57444e02-$WOODEMI_SUFFIX';
const WOODEMI_CHAR__COMMAND_RESPONSE = WOODEMI_CHAR__COMMAND_REQUEST;

const WOODEMI_MTU_WUART = 247;

class PeripheralDetailPage extends StatefulWidget {
  final String deviceId;

  PeripheralDetailPage(this.deviceId);

  @override
  State<StatefulWidget> createState() {
    return _PeripheralDetailPageState();
  }
}

class _PeripheralDetailPageState extends State<PeripheralDetailPage> {
  //create here an object of type globals that contains all the variables and need to be exchanged between pages
  Globals globals = Globals();
  bool isConnected = false; //is connected
  bool connecting = false; //connect

  @override
  void initState() {
    super.initState();
    globals.deviceId = widget.deviceId;
    QuickBlue.setConnectionHandler(_handleConnectionChange);
    QuickBlue.setServiceHandler(_handleServiceDiscovery);
    QuickBlue.setValueHandler(_handleValueChange);

    //inizialize shared preferences used also when you close the app and open it again
    createSharedPreferences();
  }

  @override
  void dispose() {
    super.dispose();
    QuickBlue.setValueHandler(null);
    QuickBlue.setServiceHandler(null);
    QuickBlue.setConnectionHandler(null);
  }

  // Retrieve configuration variables from SharedPreferences
  Future<void> createSharedPreferences() async {
    globals.prefs = await SharedPreferences.getInstance();
  }

  void _handleConnectionChange(String deviceId, BlueConnectionState state) {
    print('_handleConnectionChange $deviceId, $state');
  }

  List<String> services = [];
  Map<String, List<String>> characteristics = {};

  void _handleServiceDiscovery(
      String deviceId, String serviceId, List<String> characteristicIds) {
    print('_handleServiceDiscovery $deviceId, $serviceId, $characteristicIds');

    // Update the list of services
    setState(() {
      services = [...services, serviceId];
      characteristics[serviceId] = characteristicIds;
    });
  }

  void _handleValueChange(
      String deviceId, String characteristicId, Uint8List value) {
    print(
        '_handleValueChange $deviceId, $characteristicId, ${hex.encode(value)}');
  }

  final serviceUUID = TextEditingController(text: WOODEMI_SERV__COMMAND);
  final characteristicUUID =
      TextEditingController(text: WOODEMI_CHAR__COMMAND_REQUEST);
  final binaryCode = TextEditingController(
      text: hex.encode([0x01, 0x0A, 0x00, 0x00, 0x00, 0x01]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PeripheralDetailPage'),
      ),
      body: Column(
        children: [
          Row(
            //connect and disconnect buttons
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                child: Text('connect'),
                onPressed: connecting
                    ? null
                    : () {
                        setState(() {
                          connecting = true;
                        });
                        QuickBlue.connect(widget.deviceId);
                        Future.delayed(Duration(seconds: 2), () {
                          setState(() {
                            isConnected = true;
                          });
                        });
                      },
              ),
              ElevatedButton(
                child: Text('disconnect'),
                onPressed: () {
                  QuickBlue.disconnect(widget.deviceId);
                  setState(() {
                    isConnected = false;
                  });
                },
              ),
            ],
          ),
          Row(
            //go to the startPage page trasmitting globals.
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                child: Text('Go to command page'),
                onPressed: isConnected
                    ? () {
                        QuickBlue.discoverServices(globals.deviceId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                       //         TraxxasJoystickExample(globals: globals),
                                  Webcam(globals: globals),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
