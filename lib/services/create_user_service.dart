import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_reserve_admin/firebase_options.dart';
import 'package:smart_reserve_admin/utils/firebase_constants.dart';

class CreateUserService {
  /// Creates a new user in Firebase Auth and stores their profile data
  /// in Firestore. Uses a secondary Firebase app so the admin session
  /// is not affected.
  static Future<String?> createUser({
    required String email,
    required String password,
    required String name,
    required String staffId,
    required int slotsPerWeek,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // Initialize a secondary Firebase app for user creation
      secondaryApp = await Firebase.initializeApp(
        name: 'userCreation',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Create the user using the secondary app's auth instance
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await secondaryAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // Sign out from secondary app immediately
      await secondaryAuth.signOut();

      // Write user profile data to Firestore
      final firestore = FirebaseFirestore.instance;

      await Future.wait([
        // userName collection: name + staffId
        firestore.collection(FirebaseConstants.userName).doc(uid).set({
          'name': name,
          'staffId': staffId,
        }),

        // allottedSlots collection: weekly slot count
        firestore.collection(FirebaseConstants.allottedSlots).doc(uid).set({
          'allottedSlots': slotsPerWeek,
        }),

        // staffaccess collection: default to false
        firestore.collection(FirebaseConstants.staffAccess).doc(uid).set({
          'isadmin': false,
        }),
      ]);

      return null; // Success — no error
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'The password is too weak (min 6 characters).';
        default:
          return e.message ?? 'Authentication error occurred.';
      }
    } catch (e) {
      return e.toString();
    } finally {
      // Always clean up the secondary app
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }
}
