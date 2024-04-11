import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../widgets/ui/background_shapes.dart";
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
    if (_loginFormKey.currentState!.validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: userName.text.trim(), password: password.text);
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        print(e.code.toString());
        Navigator.pop(context);
        if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Invalid Email")));
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Check your Credentials")));
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello,",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            "Welcome Back!",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    BuildLoginTextForm(
                      controller: userName,
                      label: "Email",
                      readOnly: false,
                      obscureText: false,
                      isPassword: false,
                    ),
                    const SizedBox(height: 10.0),
                    BuildLoginTextForm(
                      controller: password,
                      label: "Password",
                      readOnly: false,
                      obscureText: true,
                      isPassword: true,
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
          )),
    );
  }
}
