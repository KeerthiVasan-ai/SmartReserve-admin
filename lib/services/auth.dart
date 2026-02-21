import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:smart_reserve_admin/utils/firebase_constants.dart";
import "../screens/login_screen.dart";
import "../screens/main_screen.dart";
import "../screens/restricted_access_screen.dart";
import "../widgets/ui/background_shapes.dart";

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _AdminGate(user: snapshot.data!);
        } else {
          return const LoginScreen();
        }
      },
    ));
  }
}

/// Checks if the authenticated user has admin access before
/// allowing entry to the main screen.
class _AdminGate extends StatelessWidget {
  final User user;
  const _AdminGate({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection(FirebaseConstants.staffAccess)
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BackgroundShapes(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Check admin access
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data['isadmin'] == true) {
            return const MainScreen();
          }
        }

        // Not admin — show restricted access and sign out
        return const RestrictedAccessScreen();
      },
    );
  }
}
