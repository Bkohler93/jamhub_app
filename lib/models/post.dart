// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uuid/uuid.dart';

class Post {
  UuidValue id;
  UuidValue userID;
  UuidValue roomID;
  String link;
  DateTime updatedAt;
  DateTime createdAt;
  Post({
    required this.id,
    required this.userID,
    required this.roomID,
    required this.link,
    required this.updatedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id.toString(),
      'user_id': userID.toString(),
      'room_id': roomID.toString(),
      'link': link,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: UuidValue.fromString(map['id']),
      userID: UuidValue.fromString(map['user_id']),
      roomID: UuidValue.fromString(map['room_id']),
      link: map['link'] as String,
      updatedAt: DateTime.parse(map['updated_at']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);
}

// {
//   "id": "111-222-333",
//   "user_id": "111-22-333",
//   "room_id": "222-333-fff",
//   "link": "spotify.com/songlink1111",
//   "created_at": "2023-01-01 12:15:00",
//   "updated_at": "2023-01-01 12:15:00"
// }