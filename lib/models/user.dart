// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uuid/uuid.dart';

class User {
  UuidValue id;
  String? email;
  String? phone;
  String displayName;
  DateTime createdAt;
  DateTime updatedAt;
  User({
    required this.id,
    required this.email,
    required this.phone,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id.toString(),
      'email': email,
      'phone': phone,
      'displayName': displayName,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: UuidValue.fromString(map['id']),
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      displayName: map['display_name'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
