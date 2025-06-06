import 'package:shared_preferences/shared_preferences.dart';

// TODO: Should be replaced with the real implementation
class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String MOCK_TOKEN = 'mock_token';
  final SharedPreferences _prefs;

  TokenService(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    // return _prefs.getString(_tokenKey);
    return MOCK_TOKEN;
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool get hasToken => getToken() != null;
}
