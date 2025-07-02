import 'package:flutter/material.dart';
import '../models/user.dart';
import 'api_client.dart';

enum AuthResult { success, unauthorized, failure }

class AuthService extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  User? _user;

  User? get currentUser => _user;

  Future<AuthResult> login(String username, String password) async {
    try {
      final data = await _client.login(username, password);
      if (data is Map && data.containsKey('access_token')) {
        final info = await _client.getCurrentUser();
        if (info is Map<String, dynamic>) {
          _user = User.fromJson(info);
        } else {
          _user = User(id: 0, username: username, email: '');
        }
        notifyListeners();
        return AuthResult.success;
      }
      return AuthResult.failure;
    } catch (e) {
      if (e.toString().contains('401')) {
        return AuthResult.unauthorized;
      }
      return AuthResult.failure;
    }
  }

  Future<bool> requestOtp(String phone) async {
    final res = await _client.requestOtp(phone);
    return res != null;
  }

  Future<AuthResult> verifyOtp(String phone, String code) async {
    try {
      final data = await _client.verifyOtp(phone, code);
      if (data is Map && data.containsKey('access_token')) {
        final info = await _client.getCurrentUser();
        if (info is Map<String, dynamic>) {
          _user = User.fromJson(info);
        }
        notifyListeners();
        return AuthResult.success;
      }
      return AuthResult.failure;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  Future<bool> register(
      String username, String email, String password) async {
    final data = await _client.register(username, email, password);
    if (data is Map<String, dynamic>) {
      _user = User.fromJson(data);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _client.updateToken(null);
    _user = null;
    notifyListeners();
  }
}
