import 'package:jamhubapp/auth/jamhub_auth.dart';
import 'package:jamhubapp/injection_container.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:riverpod/riverpod.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthUser?>((ref) => AuthNotifier());

class AccessTokenExpiredException implements Exception {}

class RefreshTokenExpiredException implements Exception {}

class AuthNotifier extends StateNotifier<AuthUser?> {
  AuthNotifier() : super(null);

  Future<AuthUser?> login(String email, String password) async {
    try {
      final user =
          await locator<AuthService>().login(email: email, password: password);

      state = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await locator<AuthService>().logout();
      state = null;
    } catch (e) {
      print(e);
    }
  }

  Future<AuthUser> refreshUserAuth() async {
    try {
      print("Refreshed user auth token");
      state = await locator<AuthService>().refresh(state!);

      return state!;
    } catch (e) {
      rethrow;
    }
  }

  void updateAuthUser(AuthUser newUser) {
    state = newUser;
  }
}
