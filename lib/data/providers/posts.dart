import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/data/service.dart';
import 'package:jamhubapp/models/post.dart';
import 'package:uuid/uuid.dart';

final roomPostsProvider =
    FutureProvider.family<List<Post>, UuidValue>((ref, roomID) async {
  final jamhubService = ref.watch(jamhubServiceProvider);

  final roomPosts = await jamhubService.getRoomPosts(roomID);

  return roomPosts;
});
