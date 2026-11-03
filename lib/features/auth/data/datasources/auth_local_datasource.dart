import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/pref_keys.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final SharedPreferences _prefs;
  const AuthLocalDataSource(this._prefs);

  Future<void> saveSession(UserModel u) async {
    await _prefs.setBool(PrefKeys.isLoggedIn, true);
    await _prefs.setString(PrefKeys.userId, u.id);
    await _prefs.setString(PrefKeys.userRole, u.role);
    await _prefs.setString(PrefKeys.userEmail, u.email);
    await _prefs.setString(PrefKeys.userName, u.name);
  }

  UserModel? getSession() {
    if (_prefs.getBool(PrefKeys.isLoggedIn) != true) return null;
    final id = _prefs.getString(PrefKeys.userId);
    final role = _prefs.getString(PrefKeys.userRole);
    if (id == null || role == null) return null;
    return UserModel(
      id: id,
      role: role,
      email: _prefs.getString(PrefKeys.userEmail) ?? '',
      name: _prefs.getString(PrefKeys.userName) ?? '',
    );
  }

  Future<void> clear() async {
    await _prefs.remove(PrefKeys.isLoggedIn);
    await _prefs.remove(PrefKeys.userId);
    await _prefs.remove(PrefKeys.userRole);
    await _prefs.remove(PrefKeys.userEmail);
    await _prefs.remove(PrefKeys.userName);
  }
}
