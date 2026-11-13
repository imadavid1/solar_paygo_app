import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';

class SessionStore {
  static const _customerSessionKey = 'customer_session';

  Future<void> saveCustomer(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _customerSessionKey,
      jsonEncode({
        'access_token': session.accessToken,
        'user_id': session.userId,
        'name': session.name,
        'email': session.email,
        'role': session.role,
      }),
    );
  }

  Future<AuthSession?> loadCustomer() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_customerSessionKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      return AuthSession.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
    } catch (_) {
      await preferences.remove(_customerSessionKey);
      return null;
    }
  }

  Future<void> clearCustomer() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_customerSessionKey);
  }
}
