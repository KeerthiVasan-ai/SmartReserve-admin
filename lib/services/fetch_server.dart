import "package:cloud_firestore/cloud_firestore.dart";
import "dart:developer" as dev;
import 'package:smart_reserve_admin/utils/firebase_constants.dart';

class FetchServerDetails {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String?> fetchPwd() async {
    try{
      DocumentSnapshot<Map<String,dynamic>> snapshot = await _firestore.collection(FirebaseConstants.constants).doc(FirebaseConstants.server).get();
      String? password = snapshot.data()?['password'];
      dev.log(password!,name: "Password");
      return password;
    } catch(error){
      dev.log(error.toString(),name:"Error");
      return null;
    }
  }

  /// Fetches server config to check maintenance status and required version.
  /// Returns a map with `isAppUnderMaintenance` (bool) and `version` (String).
  static Future<Map<String, dynamic>> checkIsAppUnderMaintenance() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(FirebaseConstants.constants)
          .doc(FirebaseConstants.server)
          .get();

      final data = snapshot.data();
      if (data == null) {
        throw Exception("Server config is null");
      }

      return {
        'isAppUnderMaintenance': data['isAdminAppUnderMaintenance'] ?? false,
        'version': data['adminVersion'] ?? 'unknown',
      };
    } catch (error) {
      dev.log(
        "Failed to fetch server details: $error",
        name: "FetchServerDetails",
      );
      return {
        'isAppUnderMaintenance': false,
        'version': 'unknown',
      };
    }
  }
}