import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  User? get currentUser => _authService.currentUser;

  AuthController() {
    _init();
  }

  void _init() {
    // Check initial session
    if (_authService.currentSession != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();

    // Listen to changes
    _authService.authStateChanges.listen((data) {
      final session = data.session;
      if (session != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signIn(email: email, password: password);
    } catch (e) {
      // Re-throw to be handled by the UI
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}
