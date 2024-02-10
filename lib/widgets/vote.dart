import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/data/providers/auth.dart';
import 'package:jamhubapp/data/providers/posts.dart';
import 'package:jamhubapp/injection_container.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:jamhubapp/models/post_vote.dart';
import 'package:uuid/uuid.dart';

class VoteWidget extends ConsumerStatefulWidget {
  VoteWidget({required this.postID});
  final UuidValue postID;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => VoteWidgetState();
}

class VoteWidgetState extends ConsumerState<VoteWidget> {
  void handleUserUpvote(AuthUser user, UuidValue postID) async {
    await locator<JamhubService>().createPostVote(user, postID, isUpvote: true);

    ref.invalidate(postVotesProvider(postID));
  }

  void handleUserDownvote(AuthUser user, UuidValue postID) async {
    await locator<JamhubService>()
        .createPostVote(user, postID, isUpvote: false);

    ref.invalidate(postVotesProvider(postID));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<PostVote>> roomVotes =
        ref.watch(postVotesProvider(widget.postID));
    final user = ref.watch(authNotifierProvider);

    return roomVotes.when(data: (roomVotes) {
      final userUpvoted = roomVotes
          .any((element) => element.userID == user!.id && element.isUp);
      final userDownvoted = roomVotes
          .any((element) => element.userID == user!.id && !element.isUp);

      final postScore = roomVotes.fold<int>(0, (previousValue, element) {
        if (element.isUp) {
          return previousValue + 1;
        } else {
          return previousValue - 1;
        }
      });
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              iconSize: 22.0,
              onPressed: userUpvoted
                  ? null
                  : () => handleUserUpvote(user!, widget.postID),
              icon: Icon(
                Icons.arrow_upward,
                color: userUpvoted ? Colors.orange : Colors.grey,
              )),
          // Text("$postScore"),
          Text("$postScore", style: TextStyle(fontSize: 12)),
          IconButton(
              iconSize: 22.0,
              onPressed: userDownvoted
                  ? null
                  : () => handleUserDownvote(user!, widget.postID),
              icon: Icon(Icons.arrow_downward,
                  color: userDownvoted ? Colors.blue : Colors.grey)),
        ],
      );
    }, error: (e, s) {
      return Text("error");
    }, loading: () {
      return Text("Loading votes");
    });
  }
}
