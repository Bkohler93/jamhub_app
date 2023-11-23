import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/auth/service.dart';
import 'package:jamhubapp/models/auth.dart';
import 'package:jamhubapp/data/service.dart';
import 'package:jamhubapp/data/providers/subscriptions.dart';

class CreateRoomPage extends StatelessWidget {
  const CreateRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Create a room")),
        body: Center(child: CreateRoomForm()));
  }
}

class CreateRoomForm extends ConsumerStatefulWidget {
  const CreateRoomForm({super.key});

  @override
  CreateRoomFormState createState() {
    return CreateRoomFormState();
  }
}

class CreateRoomFormState extends ConsumerState<CreateRoomForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController roomNameController = TextEditingController();
  AuthUser? user;

  void Function() pressCreateHandler(AuthUser u) {
    return () {
      final room = ref
          .read(jamhubServiceProvider)
          .createRoom(roomNameController.text, u);

      ref.invalidate(userSubscriptionsProvider);
      ref.invalidate(topSubscribedRoomsProvider);
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
            controller: roomNameController,
            decoration: InputDecoration(helperText: "room name"),
          ),
          ElevatedButton(
              onPressed: pressCreateHandler(user!), child: Text("Create room"))
          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}
