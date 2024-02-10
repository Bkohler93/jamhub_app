import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/auth/spotify.dart';
import 'package:jamhubapp/data/spotify.dart';
import 'package:jamhubapp/injection_container.dart';
import 'package:uuid/uuid_value.dart';

class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key, required this.postID, required this.postLink});
  final UuidValue postID;
  final String postLink;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return PostPageState();
  }
}

class PostPageState extends ConsumerState<PostPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: locator<SpotifyApiService>().getTrackInfo(
          widget.postLink,
          locator<SpotifyAuth>().accessToken,
          // ref.read(spotifyTokenProvider).accessToken,
        ),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            final spotifyData = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                  title: Column(children: [
                Text(spotifyData!.songTitle, style: TextStyle(fontSize: 20)),
                Text(spotifyData.artistName, style: TextStyle(fontSize: 14))
              ])),
            );
          } else {
            return Text("something weird happened");
          }
        }));
  }
}
