import 'package:shared_preferences/shared_preferences.dart';
import 'default.dart';

Defaults defaults = Defaults();

class Globals {
  String deviceId = '';
  String bleServiceId = '';
  String movingCharacteristicId = '';
  
  late SharedPreferences prefs; // SharedPreferences instance
}
