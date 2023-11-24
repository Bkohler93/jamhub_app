import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:jamhubapp/models/post.dart';
import 'package:jamhubapp/models/room.dart';
import 'package:jamhubapp/models/subscription.dart';
import 'package:jamhubapp/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid_value.dart';

class JamhubService {
  JamhubService() {
    baseUrl = dotenv.get("BASE_URL");
  }

  late String baseUrl;

  Future<List<SubscriptionData>> getUserSubscriptionList(AuthUser u) async {
    final res = await http.get(
      Uri.parse("${baseUrl}users/rooms/room_subscriptions"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${u.accessToken}',
      },
    );

    if (res.statusCode == HttpStatus.badRequest ||
        res.statusCode == HttpStatus.unauthorized) {
      final jsonBody = jsonDecode(res.body);

      if (jsonBody["error"] == "expired token") {
        throw AccessTokenExpiredException();
      }

      throw Exception("Bad request");
    }

    final List<dynamic> jsonList = jsonDecode(res.body);

    List<SubscriptionData> subData =
        jsonList.map((json) => SubscriptionData.fromMap(json)).toList();

    return subData;
  }

  Future<List<SubscriptionData>> getTopSuscribedRoomsList() async {
    final res = await http.get(
      Uri.parse("${baseUrl}rooms/room_subscriptions"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final List<dynamic> jsonList = jsonDecode(res.body);

    List<SubscriptionData> subData =
        jsonList.map((json) => SubscriptionData.fromMap(json)).toList();

    return subData;
  }

  Future<Room?> createRoom(String name, AuthUser u) async {
    try {
      final res = await http.post(Uri.parse("${baseUrl}rooms"),
          headers: <String, String>{
            'Authorization': 'Bearer ${u.accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            "name": name,
          }));

      if (res.statusCode == HttpStatus.badRequest ||
          res.statusCode == HttpStatus.unauthorized) {
        final jsonBody = jsonDecode(res.body);

        if (jsonBody["error"] == "expired token") {
          throw AccessTokenExpiredException();
        }

        throw Exception("Bad request");
      }

      final Room room = Room.fromJson(res.body);

      return room;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> createUser(
      {required String? email,
      required String password,
      required String displayName,
      required String? phone}) async {
    try {
      final res = await http.post(Uri.parse("${baseUrl}users"),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String?>{
            "email": email,
            "password": password,
            "display_name": displayName,
            "phone": phone,
          }));

      if (res.statusCode != HttpStatus.created) {
        final body = jsonDecode(res.body);
        throw Exception(body["error"]);
      }

      final User user = User.fromJson(res.body);
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Post>> getRoomPosts(UuidValue roomID) async {
    try {
      final res = await http.get(
        Uri.parse("${baseUrl}rooms/posts/$roomID"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (res.body == "null") {
        return [];
      }

      if (res.statusCode != HttpStatus.ok) {
        final body = jsonDecode(res.body);
        throw Exception(body['error']);
      }

      List<dynamic> resData = jsonDecode(res.body);

      List<Post> posts = resData.map((p) => Post.fromMap(p)).toList();

      return posts;
    } catch (e) {
      rethrow;
    }
  }

  Future<Post?> createPost(String link, UuidValue roomID, AuthUser u) async {
    try {
      final res = await http.post(Uri.parse("${baseUrl}posts"),
          headers: <String, String>{
            'Authorization': 'Bearer ${u.accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            "room_id": roomID.toString(),
            "link": link,
          }));

      if (res.statusCode == HttpStatus.badRequest ||
          res.statusCode == HttpStatus.unauthorized) {
        final jsonBody = jsonDecode(res.body);

        if (jsonBody["error"] == "expired token") {
          throw AccessTokenExpiredException();
        }

        throw Exception("Bad request");
      }

      final Post post = Post.fromJson(res.body);

      return post;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

final jamhubServiceProvider = Provider<JamhubService>((ref) => JamhubService());
