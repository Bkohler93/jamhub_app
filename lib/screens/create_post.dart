import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/auth/service.dart';
import 'package:jamhubapp/data/providers/posts.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:uuid/uuid_value.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({required this.roomID, super.key});
  final UuidValue roomID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create a post")),
      body: Center(
        child: CreatePostForm(
          roomID: roomID,
        ),
      ),
    );
  }
}

class CreatePostForm extends ConsumerStatefulWidget {
  const CreatePostForm({required this.roomID, super.key});
  final UuidValue roomID;

  @override
  CreatePostFormState createState() {
    return CreatePostFormState();
  }
}

class CreatePostFormState extends ConsumerState<CreatePostForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController songLinkController = TextEditingController();
  AuthUser? user;

  void Function() pressCreateHandler(AuthUser u) {
    return () {
      try {
        ref
            .read(jamhubServiceProvider)
            .createPost(songLinkController.text, widget.roomID, u);
      } catch (e) {
        if (e is AccessTokenExpiredException) {
          ref.read(authServiceProvider).refresh(u).then((updatedUser) {
            ref.read(authNotifierProvider.notifier).updateAuthUser(updatedUser);
          });
          ref
              .read(jamhubServiceProvider)
              .createPost(songLinkController.text, widget.roomID, u);
        }
        rethrow;
      }

      ref.invalidate(roomPostsProvider);
      Navigator.of(context).pop();
    };
  }

  @override
  Widget build(BuildContext context) {
    user = ref.watch(authNotifierProvider);
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: songLinkController,
            decoration: InputDecoration(helperText: "paste link here"),
          ),
          ElevatedButton(
              onPressed: pressCreateHandler(user!), child: Text("Create Post"))
          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}
