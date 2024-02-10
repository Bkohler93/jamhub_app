import 'package:jamhubapp/auth/jamhub_auth.dart';
import 'package:test/test.dart';

void main() {
  test('User should be extracted from login response', () async {
    final authService = AuthService();

    final user = await authService.login(
        email: "user1@example.com", password: "hello1234");

    expect(user.email, "user1@example.com");
  });
}
