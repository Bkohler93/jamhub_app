import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/auth/spotify.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/data/providers/posts.dart';
import 'package:jamhubapp/data/providers/subscriptions.dart';
import 'package:jamhubapp/data/spotify.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:jamhubapp/models/post.dart';
import 'package:jamhubapp/models/post_vote.dart';
import 'package:jamhubapp/screens/create_post.dart';
import 'package:uuid/uuid.dart';

class RoomPage extends ConsumerStatefulWidget {
  const RoomPage({required this.roomID, required this.roomName, super.key});
  final UuidValue roomID;
  final String roomName;

  @override
  RoomPageState createState() {
    return RoomPageState();
  }
}

class RoomPageState extends ConsumerState<RoomPage> {
  late final UuidValue roomID;
  late final String roomName;
  void Function() handleAddPost(BuildContext context) {
    return () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => CreatePostPage(
            roomID: widget.roomID,
          ),
        ),
      );
    };
  }

  @override
  void initState() {
    super.initState();
    roomID = widget.roomID;
    roomName = widget.roomName;
  }

  void handleUserUpvote(AuthUser user, UuidValue postID) async {
    // create post vote
    await ref
        .read(jamhubServiceProvider)
        .createPostVote(user, postID, isUpvote: true);

    // invalidate
    ref.invalidate(postVotesProvider(postID));
  }

  void handleUserDownvote(AuthUser user, UuidValue postID) async {
    // create post vote
    await ref
        .read(jamhubServiceProvider)
        .createPostVote(user, postID, isUpvote: false);

    // invalidate
    ref.invalidate(postVotesProvider(postID));
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<Post>> posts = ref.watch(roomPostsProvider(roomID));
    AsyncValue<bool> isSubscribed =
        ref.watch(isUserSubscribedToRoomProvider(roomID));
    final user = ref.watch(authNotifierProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(roomName),
          actions: [
            isSubscribed.when(data: (value) {
              if (value) {
                return TextButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(jamhubServiceProvider)
                          .unsubscribeFromRoom(user!, roomID);
                      ref.invalidate(isUserSubscribedToRoomProvider(roomID));
                      ref.invalidate(userSubscriptionsProvider);
                    } catch (e) {}
                  },
                  child: const Text("Unsubscribe"),
                );
              } else {
                return TextButton(
                  onPressed: () async {
                    //subscribe
                    try {
                      await ref
                          .read(jamhubServiceProvider)
                          .subscribeToRoom(user!, roomID);
                      ref.invalidate(isUserSubscribedToRoomProvider(roomID));
                      ref.invalidate(userSubscriptionsProvider);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text("Subscribe"),
                );
              }
            }, error: (e, s) {
              print(e);
              return const TextButton(
                onPressed: null,
                child: Text("error"),
              );
            }, loading: () {
              return const TextButton(onPressed: null, child: Text("loading"));
            })
          ],
        ),
        floatingActionButton: IconButton(
          color: Theme.of(context).primaryColor,
          onPressed: handleAddPost(context),
          icon: const Icon(Icons.add),
        ),
        body: Center(
          child: posts.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, stackTrace) =>
                Text("error retrieving room's posts - ${e.toString()}"),
            data: (posts) {
              if (posts.isEmpty) {
                return const Text("This room doesn't have any posts yet :(");
              }
              return Column(
                children: List.generate(
                  posts.length,
                  (i) => SizedBox(
                      width: 80.w,
                      child: FutureBuilder(
                          future: SpotifyApiService.getTrackInfo(
                            posts[i].link,
                            ref.read(spotifyTokenProvider).accessToken,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              final AsyncValue<List<PostVote>> roomVotes =
                                  ref.watch(postVotesProvider(posts[i].id));

                              return Row(
                                children: [
                                  roomVotes.when(data: (roomVotes) {
                                    final userUpvoted = roomVotes.any(
                                        (element) =>
                                            element.userID == user!.id &&
                                            element.isUp);
                                    final userDownvoted = roomVotes.any(
                                        (element) =>
                                            element.userID == user!.id &&
                                            !element.isUp);

                                    final postScore = roomVotes.fold<int>(0,
                                        (previousValue, element) {
                                      if (element.isUp) {
                                        return previousValue + 1;
                                      } else {
                                        return previousValue - 1;
                                      }
                                    });
                                    return Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                              iconSize: 22.0,
                                              onPressed: userUpvoted
                                                  ? null
                                                  : () => handleUserUpvote(
                                                      user!, posts[i].id),
                                              icon: Icon(
                                                Icons.arrow_upward,
                                                color: userUpvoted
                                                    ? Colors.orange
                                                    : Colors.grey,
                                              )),
                                          // Text("$postScore"),
                                          Text("$postScore",
                                              style: TextStyle(fontSize: 12)),
                                          IconButton(
                                              iconSize: 22.0,
                                              onPressed: userDownvoted
                                                  ? null
                                                  : () => handleUserDownvote(
                                                      user!, posts[i].id),
                                              icon: Icon(Icons.arrow_downward,
                                                  color: userDownvoted
                                                      ? Colors.blue
                                                      : Colors.grey)),
                                        ],
                                      ),
                                    );
                                  }, error: (e, s) {
                                    return Text("error");
                                  }, loading: () {
                                    return CircularProgressIndicator();
                                  }),
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.2), // Adjust the color and opacity
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: const Offset(2,
                                              2), // Adjust the position of the shadow
                                        ),
                                      ],
                                    ),
                                    child: Image.network(
                                      snapshot.data!.thumbnailUrl,
                                      // You can add more properties to customize the image display, such as width, height, fit, etc.
                                      width: 64.0,
                                      height: 64.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(snapshot.data!.songTitle,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            )),
                                        Text(snapshot.data!.artistName),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                              // return _buildSongData(snapshot.data!);
                            } else {
                              return const Text('Something went wrong');
                            }
                          })

                      // Column(
                      //   children: [

                      //     Text(posts[i].link)],
                      // ),
                      ),
                ),
              );
            },
          ),
        ));
  }
}
