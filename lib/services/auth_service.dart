import '../models/user.dart';

class AuthService {
  User? _user;

  User? get currentUser => _user;

  Future<bool> login(String username, String password) async {
    // simple local check
    if (username.isNotEmpty && password.isNotEmpty) {
      _user = User(username);
      return true;
    }
    return false;
  }

  void logout() {
    _user = null;
  }
}
