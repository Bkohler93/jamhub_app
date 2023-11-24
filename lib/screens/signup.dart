import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/models/user.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text("Requires email or phone number to create an account"),
              SignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  SignupFormState createState() {
    return SignupFormState();
  }
}

// {
//   "email": "example@gmail.com",
//   "password": "password1234",
//   "display_name": "display nme",
//   "phone": "555-123-4567"
// }

class SignupFormState extends ConsumerState<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  User? user;

  void Function() pressCreateHandler() {
    return () {
      final user = ref.read(jamhubServiceProvider).createUser(
            email: emailController.text,
            password: passwordController.text,
            phone: phoneController.text,
            displayName: displayNameController.text,
          );
      user.then(
        (u) {
          if (u != null) {
            Navigator.of(context).pop();
          } else {
            print("error creating user");
          }
        },
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    // user = ref.watch(authNotifierProvider);
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(helperText: "email"),
            controller: emailController,
          ),
          TextFormField(
            decoration: InputDecoration(helperText: "password"),
            controller: passwordController,
          ),
          TextFormField(
            decoration: InputDecoration(helperText: "display name"),
            controller: displayNameController,
          ),
          TextFormField(
            decoration: InputDecoration(helperText: "phone number"),
            controller: phoneController,
          ),

          ElevatedButton(onPressed: pressCreateHandler(), child: Text("Done"))
          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}
