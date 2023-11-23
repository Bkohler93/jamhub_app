// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uuid/uuid_value.dart';

class Room {
  UuidValue id;
  String? name;
  DateTime createdAt;
  DateTime updatedAt;
  Room({
    required this.id,
    this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id.toString(),
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      // id: UuidValue.fromMap(map['id'] as Map<String,dynamic>),
      id: UuidValue.fromString(map['id']),
      name: map['name'] != null ? map['name'] as String : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Room.fromJson(String source) =>
      Room.fromMap(json.decode(source) as Map<String, dynamic>);
}
