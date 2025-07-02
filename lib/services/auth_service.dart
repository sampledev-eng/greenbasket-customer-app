import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();
  User? _user;

  User? get currentUser => _user;

  Future<bool> login(String username, String password) async {
    final data = await _client.login(username, password);
    if (data is Map && data.containsKey('access_token')) {
      final info = await _client.getCurrentUser();
      if (info is Map<String, dynamic>) {
        _user = User.fromJson(info);
      } else {
        _user = User(id: 0, username: username, email: '');
      }
      return true;
    }
    return false;
  }

  Future<bool> register(
      String username, String email, String password) async {
    final data = await _client.register(username, email, password);
    if (data is Map<String, dynamic>) {
      _user = User.fromJson(data);
      return true;
    }
    return false;
  }

  void logout() {
    _client.updateToken(null);
    _user = null;
  }
}
