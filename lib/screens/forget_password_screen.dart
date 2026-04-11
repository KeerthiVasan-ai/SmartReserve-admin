import "package:firebase_auth/firebase_auth.dart";
import "dart:developer" as dev;
import "package:flutter/material.dart";
import 'package:smart_reserve_admin/services/gcp_logging_service.dart';
import '../widgets/ui/background_shapes.dart';
import '../widgets/build_app_bar.dart';
import '../widgets/build_elevated_button.dart';
import '../widgets/build_login_text_form.dart';
import 'login_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController mail = TextEditingController();

  void _sendMail() async {
    if (_forgetPasswordFormKey.currentState!.validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: mail.text.trim());
        GCPLog.info('Password reset email sent', userId: mail.text.trim());
        dev.log("Mail Sent", name: "Success");
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Mail Sent")));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        GCPLog.warning('Password reset failed: ${e.code}', userId: mail.text.trim());
        if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Invalid Email")));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
        }
      } catch (e) {
        Navigator.pop(context);
        dev.log(e.toString(), name: "Error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const BuildAppBar(title: "Forget Password"),
        body: SafeArea(
          child: Center(
            child: Form(
              key: _forgetPasswordFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 0.0,
                      horizontal: 30.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Get Back your Account!",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  BuildLoginTextForm(
                    controller: mail,
                    label: "Email",
                    readOnly: false,
                    obscureText: false,
                    isPassword: false,
                  ),
                  const SizedBox(height: 10.0),
                  BuildElevatedButton(
                    actionOnButton: _sendMail,
                    buttonText: "Get Password Reset Link",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
