import "package:cloud_firestore/cloud_firestore.dart";
import "dart:developer" as dev;

class FetchServerDetails {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String?> fetchPwd() async {
    try{
      DocumentSnapshot<Map<String,dynamic>> snapshot = await _firestore.collection("constants").doc("server").get();
      String? password = snapshot.data()?['password'];
      dev.log(password!,name: "Password");
      return password;
    } catch(error){
      dev.log(error.toString(),name:"Error");
      return null;
    }
  }
}