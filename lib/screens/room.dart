import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jamhubapp/auth/spotify.dart';
import 'package:jamhubapp/data/providers/posts.dart';
import 'package:jamhubapp/data/spotify.dart';
import 'package:jamhubapp/models/post.dart';
import 'package:jamhubapp/screens/create_post.dart';
import 'package:uuid/uuid.dart';

class RoomPage extends ConsumerWidget {
  const RoomPage({required this.roomID, required this.roomName, super.key});
  final UuidValue roomID;
  final String roomName;

  void Function() handleAddPost(BuildContext context) {
    return () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => CreatePostPage(
            roomID: roomID,
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Post>> posts = ref.watch(roomPostsProvider(roomID));
    return Scaffold(
        appBar: AppBar(
          title: Text(roomName),
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
