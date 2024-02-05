import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamhubapp/auth/auth.dart';
import 'package:jamhubapp/screens/home.dart';
import 'package:jamhubapp/screens/signup.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController loginController;
  late TextEditingController passwordController;
  late GlobalKey<FormState> formKey;
  bool showPasswordError = false;

  void signIn() async {
    if (formKey.currentState!.validate()) {
      final loginResult = await ref
          .read(authNotifierProvider.notifier)
          .login(loginController.text, passwordController.text);

      if (loginResult != null) {
        navigateTo(() => const HomePage());
      } else {
        print("Login Failed!");
      }
    }
  }

  void navigateTo(Widget Function() screen) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => screen()));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider);
    loginController = TextEditingController();
    passwordController = TextEditingController();
    formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text("JamHub")),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: user == null
                ? Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an email or phone number.";
                            }
                            return null;
                          },
                          controller: loginController,
                          decoration: InputDecoration(
                              hintText: "Use your email or phone number",
                              helperText: "Login"),
                        ),
                        TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a password.";
                              }
                              return null;
                            },
                            obscureText: true,
                            controller: passwordController,
                            decoration: InputDecoration(
                                helperText: "Password",
                                hintText: "Enter password here")),
                        ElevatedButton(
                          onPressed: signIn,
                          child: const Text("Sign in"),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return const SignupPage();
                              }));
                            },
                            child: const Text("Sign up here"))
                      ],
                    ),
                  )
                : const Text("Logging in!"),
          ),
        ),
      ),
    );
  }
}
