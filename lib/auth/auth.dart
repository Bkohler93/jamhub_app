import 'package:jamhubapp/auth/service.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:riverpod/riverpod.dart';

class AccessTokenExpiredException implements Exception {}

class RefreshTokenExpiredException implements Exception {}

class AuthNotifier extends StateNotifier<AuthUser?> {
  AuthNotifier(this.ref) : super(null);
  StateNotifierProviderRef ref;

  Future<AuthUser?> login(String email, String password) async {
    final authService = ref.read(authServiceProvider);

    try {
      final user = await authService.login(email: email, password: password);

      state = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);

    try {
      await authService.logout();
      state = null;
    } catch (e) {
      print(e);
    }
  }

  void updateAuthUser(AuthUser newUser) {
    state = newUser;
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthUser?>((ref) => AuthNotifier(ref));
