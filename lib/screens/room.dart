import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jamhubapp/data/providers/auth.dart';
import 'package:jamhubapp/auth/spotify.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/data/providers/posts.dart';
import 'package:jamhubapp/data/providers/subscriptions.dart';
import 'package:jamhubapp/data/spotify.dart';
import 'package:jamhubapp/injection_container.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:jamhubapp/models/post.dart';
import 'package:jamhubapp/models/post_vote.dart';
import 'package:jamhubapp/screens/create_post.dart';
import 'package:jamhubapp/screens/post.dart';
import 'package:jamhubapp/widgets/vote.dart';
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

  void Function() handleGoToPostPage(
      BuildContext context, UuidValue postID, String postLink) {
    return () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              PostPage(postID: postID, postLink: postLink)));
    };
  }

  @override
  void initState() {
    super.initState();
    roomID = widget.roomID;
    roomName = widget.roomName;
  }

  @override
  Widget build(BuildContext context) {
    print("building room page....");
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
                      await locator<JamhubService>()
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
                      await locator<JamhubService>()
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
            loading: () => Text("Loading posts"),
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
                          future: locator<SpotifyApiService>().getTrackInfo(
                            posts[i].link,
                            locator<SpotifyAuth>().accessToken,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Loading track infos");
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              final AsyncValue<List<PostVote>> roomVotes =
                                  ref.watch(postVotesProvider(posts[i].id));

                              return Row(
                                children: [
                                  VoteWidget(postID: posts[i].id),
                                  GestureDetector(
                                    onTap: handleGoToPostPage(
                                        context, posts[i].id, posts[i].link),
                                    child: Container(
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
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: handleGoToPostPage(
                                          context, posts[i].id, posts[i].link),
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
