// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uuid/uuid.dart';

class PostVote {
  UuidValue postID;
  UuidValue userID;
  bool isUp;
  DateTime updatedAt;
  DateTime createdAt;
  PostVote({
    required this.userID,
    required this.postID,
    required this.isUp,
    required this.updatedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userID.toString(),
      'room_id': postID.toString(),
      'is_up': isUp,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PostVote.fromMap(Map<String, dynamic> map) {
    return PostVote(
      userID: UuidValue.fromString(map['user_id']),
      postID: UuidValue.fromString(map['post_id']),
      isUp: map['is_up'],
      updatedAt: DateTime.parse(map['updated_at']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostVote.fromJson(String source) =>
      PostVote.fromMap(json.decode(source) as Map<String, dynamic>);
}

// {
//   "user_id": "111-22-333",
//   "post_id": "222-333-fff",
//   "is_up": true,
//   "created_at": "2023-01-01 12:15:00",
//   "updated_at": "2023-01-01 12:15:00"
// }