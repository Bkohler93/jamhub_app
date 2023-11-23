// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uuid/uuid.dart';

class SubscriptionData {
  UuidValue roomID;
  String roomName;
  DateTime createdAt;
  DateTime updatedAt;
  int subscriptionCount;

  SubscriptionData(
      {required this.roomID,
      required this.roomName,
      required this.createdAt,
      required this.updatedAt,
      required this.subscriptionCount});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'room_id': roomID,
      'room_name': roomName,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'subscription_count': subscriptionCount,
    };
  }

  factory SubscriptionData.fromMap(Map<String, dynamic> map) {
    return SubscriptionData(
      roomID: UuidValue.fromString(map['room_id']),
      roomName: map['room_name'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      subscriptionCount: map['subscription_count'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubscriptionData.fromJson(String source) =>
      SubscriptionData.fromMap(json.decode(source) as Map<String, dynamic>);
}
