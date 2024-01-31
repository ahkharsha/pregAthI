import 'package:shared_preferences/shared_preferences.dart';

class UserSharedPreference {
  static SharedPreferences? _preferences;
  static const String key = 'userRole';

  static init() async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences;
  }

  static Future setUserRole(String role) async {
    return await _preferences!.setString(key, role);
  }

  static Future<String>? getUserRole() async =>
      await _preferences!.getString(key) ?? "";
}
