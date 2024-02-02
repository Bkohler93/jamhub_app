import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/auth/spotify.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/data/providers/posts.dart';
import 'package:jamhubapp/data/providers/subscriptions.dart';
import 'package:jamhubapp/data/spotify.dart';
import 'package:jamhubapp/models/post.dart';
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
                  child: Text("Unsubscribe"),
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
                  child: Text("Subscribe"),
                );
              }
            }, error: (e, s) {
              print(e);
              return TextButton(
                child: Text("error"),
                onPressed: null,
              );
            }, loading: () {
              return TextButton(child: Text("loading"), onPressed: null);
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
                  (i) => Container(
                      height: 10.h,
                      width: 80.w,
                      child: FutureBuilder(
                          future: SpotifyApiService.getTrackInfo(
                            posts[i].link,
                            ref.read(spotifyTokenProvider).accessToken,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              return Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.2), // Adjust the color and opacity
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: Offset(2,
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
                                            style: TextStyle(
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
                              return Text('Something went wrong');
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
