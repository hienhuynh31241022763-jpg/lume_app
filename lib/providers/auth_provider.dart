import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String? _name;
  String? _email;

  bool get isLoggedIn => _email != null;
  String get name => _name ?? 'Khách';
  String get email => _email ?? '';

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (password.length < 6) return false;
    _email = email.trim();
    _name = _email!.split('@').first;
    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (password.length < 6) return false;
    _name = name.trim();
    _email = email.trim();
    notifyListeners();
    return true;
  }

  void logout() {
    _name = null;
    _email = null;
    notifyListeners();
  }
}
