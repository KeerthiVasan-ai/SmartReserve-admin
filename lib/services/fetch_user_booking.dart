import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:developer" as dev;
import 'package:smart_reserve_admin/utils/firebase_constants.dart';

class FetchUserBooking {
  static Stream<QuerySnapshot> fetchBookingDetails(String date) {
    dev.log(date);
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.bookingDetails)
        .doc(date)
        .collection(FirebaseConstants.booking)
        .orderBy("slotKey")
        .snapshots();
  }
}
