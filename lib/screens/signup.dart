import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/data/jamhub.dart';
import 'package:jamhubapp/injection_container.dart';
import 'package:jamhubapp/models/user.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
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
  final formKey = GlobalKey<FormState>();
  TextEditingController emailPhoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();

  User? user;

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  bool validatePhone(String value) {
    if (value.length != 10) {
      return false;
    } else {
      return true;
    }
  }

  void pressCreateHandler() async {
    if (formKey.currentState!.validate()) {
      String email = "";
      String phone = "";
      if (validateEmail(emailPhoneController.text)) {
        email = emailPhoneController.text;
      } else {
        phone = emailPhoneController.text;
      }
      final user = await locator<JamhubService>().createUser(
        email: email,
        password: passwordController.text,
        phone: phone,
        displayName: displayNameController.text,
      );

      if (user != null) {
        Navigator.of(context).pop();
      } else {
        print("Signup failed!");
      }
    }
  }

  bool fieldEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // user = ref.watch(authNotifierProvider);
    // Build a Form widget using the _formKey created above.
    return Form(
      autovalidateMode: AutovalidateMode.always,
      key: formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null) {
                return "Requires an email or phone number.";
              }
              bool isEmail = validateEmail(value);
              bool isPhone = validatePhone(value);
              if (!isEmail && !isPhone) {
                return "You have entered an invalid email or phone number.";
              }
              return null;
            },
            decoration:
                const InputDecoration(helperText: "email or phone number"),
            controller: emailPhoneController,
          ),
          TextFormField(
            decoration: const InputDecoration(helperText: "password"),
            controller: passwordController,
            obscureText: true,
          ),
          TextFormField(
            decoration: const InputDecoration(helperText: "display name"),
            controller: displayNameController,
          ),

          ElevatedButton(
              onPressed: pressCreateHandler, child: const Text("Done"))
          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}
