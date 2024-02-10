import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jamhubapp/data/providers/auth.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:jamhubapp/models/post.dart';
import 'package:jamhubapp/models/post_vote.dart';
import 'package:jamhubapp/models/room.dart';
import 'package:jamhubapp/models/subscription.dart';
import 'package:jamhubapp/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid_value.dart';

class BadRequestJamhubException implements Exception {
  BadRequestJamhubException(this.errorMsg);
  final String errorMsg;
}

class NotFoundJamhubException implements Exception {
  NotFoundJamhubException(this.errorMsg);
  final String errorMsg;
}

class InternalServerErrorJamhubException implements Exception {
  InternalServerErrorJamhubException(this.errorMsg);
  final String errorMsg;
}

class JamhubService {
  JamhubService() {
    baseUrl = dotenv.get("BASE_URL");
  }

  late String baseUrl;

  Future<void> createPostVote(AuthUser user, UuidValue postID,
      {required bool isUpvote}) async {
    final res = await http.post(Uri.parse("${baseUrl}post_votes"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${user.accessToken}'
        },
        body: jsonEncode(<String, dynamic>{
          "post_id": postID.uuid,
          "is_upvote": isUpvote,
        }));

    if (res.statusCode != HttpStatus.ok) {
      final jsonBody = jsonDecode(res.body);
      final err = jsonBody["error"];

      switch (res.statusCode) {
        case HttpStatus.badRequest:
          throw BadRequestJamhubException(err);
        case HttpStatus.notFound:
          throw NotFoundJamhubException(err);
        case HttpStatus.internalServerError:
          throw InternalServerErrorJamhubException(err);
      }
    } else {
      print("upvoted post $postID");
    }
  }

  Future<List<PostVote>> getPostPostVotes(UuidValue postID) async {
    final res = await http.get(
        Uri.parse("${baseUrl}posts/${postID}/post_votes"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        });

    if (res.statusCode != HttpStatus.ok) {
      final jsonBody = jsonDecode(res.body);
      final err = jsonBody["error"];

      switch (res.statusCode) {
        case HttpStatus.badRequest:
          throw BadRequestJamhubException(err);
        case HttpStatus.internalServerError:
          throw InternalServerErrorJamhubException(err);
        default:
          throw Exception("Unknown error has occured: $err");
      }
    } else {
      final List<dynamic> jsonList = jsonDecode(res.body);

      List<PostVote> postVotes =
          jsonList.map((json) => PostVote.fromMap(json)).toList();

      return postVotes;
    }
  }

  /// checks if user is subscribed to room with matching roomID
  Future<bool> checkIfUserSubscribedToRoom(AuthUser u, UuidValue roomID) async {
    final subData = await getUserSubscriptionList(u);

    return subData.any((element) => element.roomID == roomID);
  }

  Future<void> unsubscribeFromRoom(AuthUser u, UuidValue roomID) async {
    final res = await http.delete(
      Uri.parse("${baseUrl}room_subs/$roomID"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${u.accessToken}'
      },
    );

    if (res.statusCode != HttpStatus.ok) {
      final jsonBody = jsonDecode(res.body);
      final err = jsonBody["error"];

      switch (res.statusCode) {
        case HttpStatus.badRequest:
          throw BadRequestJamhubException(err);
        case HttpStatus.internalServerError:
          throw InternalServerErrorJamhubException(err);
      }
    } else {
      print("unsubscibed to room");
    }
    // 400 bad request
    // 500 internal server error
  }

  Future<void> subscribeToRoom(AuthUser u, UuidValue roomID) async {
    final res = await http.post(
      Uri.parse("${baseUrl}room_subs"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${u.accessToken}',
      },
      body: jsonEncode(
        <String, String>{
          "room_id": roomID.uuid,
        },
      ),
    );

    if (res.statusCode != HttpStatus.created) {
      final jsonBody = jsonDecode(res.body);
      final err = jsonBody["error"];

      switch (res.statusCode) {
        case HttpStatus.badRequest:
          print("bad request: " + err);
          throw BadRequestJamhubException(err);

        case HttpStatus.notFound:
          print("no room exists: " + err);
          throw NotFoundJamhubException(err);
        case HttpStatus.internalServerError:
          print("internal server error: " + err);
          throw InternalServerErrorJamhubException(err);
      }
    } else {
      print("subscribed to room!");
    }
  }

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
        throw Exception("status code: ${res.statusCode}\t${body['error']}");
      }

      final User user = User.fromJson(res.body);
      return user;
    } catch (e) {
      print("error creating user: $e");
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
