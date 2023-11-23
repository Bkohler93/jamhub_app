import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jamhubapp/models/auth.dart';
import 'package:riverpod/riverpod.dart';

class AuthService {
  AuthService() {
    baseUrl = dotenv.get("BASE_URL");
  }
  late String baseUrl;

  Future<AuthUser> login(
      {required String email, required String password}) async {
    final baseUrl = dotenv.get("BASE_URL");
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

  Future<void> logout() async {}
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
