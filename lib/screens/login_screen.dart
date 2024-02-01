import "package:firebase_auth/firebase_auth.dart";
import "dart:developer" as dev;
import "package:flutter/material.dart";

import "../widgets/build_app_bar.dart";
import "/widgets/build_elevated_button.dart";
import "/widgets/build_login_text_form.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController userName = TextEditingController();
  final TextEditingController password = TextEditingController();

  void _login() async {
    if(_loginFormKey.currentState!.validate()){
      showDialog(context:context, builder: (context){
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: userName.text, password: password.text);
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        if (e.code == 'user-not-found') {
          dev.log("Wrong Mail", name: "Error");
        } else if (e.code == 'wrong-password') {
          dev.log("Wrong Password", name: "Error");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar("Login"),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background/check2.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Hello, Welcome Back!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    BuildLoginTextForm(
                      controller: userName,
                      label: "UserName",
                      readOnly: false,
                      obscureText: false,
                    ),
                    const SizedBox(height: 10.0),
                    BuildLoginTextForm(
                      controller: password,
                      label: "Password",
                      readOnly: false,
                      obscureText: true,
                    ),
                    const SizedBox(height: 10.0),
                    BuildElevatedButton(
                      actionOnButton: _login,
                      buttonText: "Login",
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}