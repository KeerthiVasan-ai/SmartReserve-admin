import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:developer" as dev;

class DeleteBooking {
  static Future<void> deleteBookingDetails(
      String collectionName, String innerCollectionName) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot collections =
          await firestore.collection(collectionName).get();
      for (QueryDocumentSnapshot collection in collections.docs) {
        QuerySnapshot innerCollections = await firestore
            .collection(collectionName)
            .doc(collection.id)
            .collection(innerCollectionName)
            .get();
        for (QueryDocumentSnapshot innerCollection in innerCollections.docs) {
          await firestore
              .collection(collectionName)
              .doc(collection.id)
              .collection(innerCollectionName)
              .doc(innerCollection.id)
              .delete();
        }
        await firestore.collection(collectionName).doc(collection.id).delete();
      }
    } catch (error) {
      dev.log(error.toString(), name: "Error");
    }
  }
}
