import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _loading = false;
  String? _error;

  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  Stream<User?> get authStateChanges => _authService.authStateChanges;
  bool get loading => _loading;
  String? get error => _error;
  bool get isSignedIn => _user != null;

  Future<bool> signIn(String email, String password) async {
    return _run(() => _authService.signIn(email, password));
  }

  Future<bool> signUp(String email, String password) async {
    return _run(() => _authService.signUp(email, password));
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> _run(Future<dynamic> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyAuthError(e.code);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
