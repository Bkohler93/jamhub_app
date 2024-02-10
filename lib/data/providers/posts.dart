import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/injection_container.dart';
import 'package:jamhubapp/models/post.dart';
import 'package:jamhubapp/models/post_vote.dart';
import 'package:uuid/uuid.dart';

final roomPostsProvider =
    FutureProvider.family<List<Post>, UuidValue>((ref, roomID) async {
  final roomPosts = await locator<JamhubService>().getRoomPosts(roomID);

  return roomPosts;
});

final postVotesProvider = FutureProvider.family<List<PostVote>, UuidValue>(
  (ref, roomID) async {
    final postVotes = await locator<JamhubService>().getPostPostVotes(roomID);

    return postVotes;
  },
);
