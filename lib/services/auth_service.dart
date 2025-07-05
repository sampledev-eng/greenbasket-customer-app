import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

enum AuthResult { success, unauthorized, failure }

class AuthService extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  User? _user;
  SharedPreferences? _prefs;
  bool _initialized = false;

  bool get initialized => _initialized;

  AuthService() {
    _load();
  }

  User? get currentUser => _user;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _prefs = prefs;
      _client.updateToken(token);
      try {
        final info = await _client.getCurrentUser();
        if (info is Map<String, dynamic>) {
          _user = User.fromJson(info);
        }
      } catch (_) {}
    }
    _initialized = true;
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final data = await _client.login(email, password);
      if (data is Map && data.containsKey('access_token')) {
        _prefs ??= await SharedPreferences.getInstance();
        final prefs = _prefs;
        if (prefs != null) {
          await prefs.setString('token', data['access_token'] as String);
        }
        final info = await _client.getCurrentUser();
        if (info is Map<String, dynamic>) {
          _user = User.fromJson(info);
        } else {
          _user = User(id: 0, username: email, email: email);
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
        _prefs ??= await SharedPreferences.getInstance();
        final prefs = _prefs;
        if (prefs != null) {
          await prefs.setString('token', data['access_token'] as String);
        }
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
      if (data.containsKey('access_token')) {
        _prefs ??= await SharedPreferences.getInstance();
        final token = data['access_token'] as String;
        final prefs = _prefs;
        if (prefs != null) {
          await prefs.setString('token', token);
        }
        _client.updateToken(token);
        final info = await _client.getCurrentUser();
        if (info is Map<String, dynamic>) {
          _user = User.fromJson(info);
        }
      } else {
        _user = User.fromJson(data);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<User?> fetchCurrentUser() async {
    try {
      final info = await _client.getCurrentUser();
      if (info is Map<String, dynamic>) {
        _user = User.fromJson(info);
        notifyListeners();
        return _user;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateProfile(String name, String email) async {
    try {
      final data =
          await _client.updateCurrentUser({'name': name, 'email': email});
      if (data is Map<String, dynamic>) {
        _user = User.fromJson(data);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  void logout() {
    _client.updateToken(null);
    _prefs?.remove('token');
    _user = null;
    notifyListeners();
  }
}
