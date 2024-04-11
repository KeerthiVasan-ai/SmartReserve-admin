import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:developer" as dev;

class FetchUserBooking {
  static Stream<QuerySnapshot> fetchBookingDetails(String date) {
    dev.log(date);
    return FirebaseFirestore.instance
        .collection('bookingDetails')
        .doc(date)
        .collection('booking').orderBy("slotKey")
        .snapshots();
  }
}