import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jamhubapp/data/providers/posts.dart';
import 'package:jamhubapp/models/post.dart';
import 'package:uuid/uuid.dart';

class RoomPage extends ConsumerWidget {
  const RoomPage({required this.roomID, required this.roomName, super.key});
  final UuidValue roomID;
  final String roomName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Post>> posts = ref.watch(roomPostsProvider(roomID));
    return Scaffold(
        appBar: AppBar(
          title: Text(roomName),
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
                    child: Column(
                      children: [Text(posts[i].link)],
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
