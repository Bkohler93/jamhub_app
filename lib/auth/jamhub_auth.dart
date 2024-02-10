import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jamhubapp/models/auth.dart';

class AuthService {
  AuthService() {
    baseUrl = dotenv.get("BASE_URL");
  }
  late String baseUrl;

  Future<AuthUser> login(
      {required String email, required String password}) async {
    final response = await http.post(
      Uri.parse("${baseUrl}auth/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          "email": email,
          "password": password,
        },
      ),
    );
    final user = AuthUser.fromJson(response.body);
    return user;
  }

  Future<AuthUser> refresh(AuthUser u) async {
    final response = await http.post(
      Uri.parse("${baseUrl}auth/refresh"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${u.refreshToken}',
      },
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    u.accessToken = jsonBody["access_token"];

    return u;
  }

  Future<void> logout() async {}
}
