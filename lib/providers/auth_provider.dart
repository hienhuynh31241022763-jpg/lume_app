import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  StreamSubscription<User?>? _sub;

  AuthProvider() {
    _user = _auth.currentUser;
    _sub = _auth.userChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get isLoggedIn => _user != null;

  String get name {
    final n = _user?.displayName?.trim() ?? '';
    if (n.isNotEmpty) return n;
    final e = _user?.email ?? '';
    return e.contains('@') ? e.split('@').first : e;
  }

  String get email => _user?.email ?? '';

  bool get emailVerified => _user?.emailVerified ?? false;

  /// Trả về null nếu thành công, trả về câu báo lỗi tiếng Việt nếu thất bại.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    } catch (_) {
      return 'Có lỗi xảy ra, vui lòng thử lại';
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
      _user = _auth.currentUser;
      notifyListeners();
      // Gửi email xác nhận đăng ký
      try {
        await _auth.currentUser?.sendEmailVerification();
      } catch (_) {}
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    } catch (_) {
      return 'Có lỗi xảy ra, vui lòng thử lại';
    }
  }

  Future<String?> loginWithGoogle() async {
    try {
      await _auth.signInWithProvider(GoogleAuthProvider());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        return 'Bạn đã hủy đăng nhập Google';
      }
      return _message(e);
    } catch (_) {
      return 'Không đăng nhập được bằng Google, vui lòng thử lại';
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    } catch (_) {
      return 'Có lỗi xảy ra, vui lòng thử lại';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email này đã được đăng ký, hãy đăng nhập';
      case 'invalid-email':
        return 'Email chưa đúng định dạng';
      case 'weak-password':
        return 'Mật khẩu quá yếu, cần từ 6 ký tự trở lên';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu chưa đúng';
      case 'user-disabled':
        return 'Tài khoản này đã bị khóa';
      case 'too-many-requests':
        return 'Bạn thử quá nhiều lần, vui lòng đợi một lúc rồi thử lại';
      case 'network-request-failed':
        return 'Không có kết nối mạng, vui lòng kiểm tra lại';
      default:
        return 'Có lỗi xảy ra (${e.code}), vui lòng thử lại';
    }
  }
}
