// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uuid/uuid.dart';

class AuthUser {
  UuidValue id;
  String? email;
  String? phone;
  String displayName;
  String accessToken;
  String refreshToken;
  AuthUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.displayName,
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id.toString(),
      'email': email,
      'phone': phone,
      'displayName': displayName,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: UuidValue.fromString(map['id']),
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      displayName: map['display_name'] as String,
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthUser.fromJson(String source) =>
      AuthUser.fromMap(json.decode(source) as Map<String, dynamic>);
}
