import 'dart:convert';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';

import 'package:smart_reserve_admin/services/gcp_credentials.dart';
import 'package:smart_reserve_admin/services/gcp_logging_service.dart';
import 'package:smart_reserve_admin/utils/firebase_constants.dart';

class DeleteUserService {
  /// Completely deletes a user's Firebase Auth account, removes their future bookings,
  /// frees up future reserved time slots, and deletes their profile collections.
  /// Retains past bookings for historical/statistical purposes.
  static Future<String?> deleteUserCompletely(String uid) async {
    try {
      dev.log('Starting deletion process for user: $uid', name: 'DeleteUserService');
      GCPLog.info('Initiating deletion process for user account.', userId: uid);

      // 1. Authenticate with Service Account to delete from Firebase Auth
      await GCPCredentials.instance.load();
      final credentials = GCPCredentials.instance.serviceAccountCredentials;
      final projectId = GCPCredentials.instance.projectId;

      final scopes = [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/firebase'
      ];
      final client = await clientViaServiceAccount(credentials, scopes);

      final deleteUrl = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/projects/$projectId/accounts:delete',
      );

      final response = await client.post(
        deleteUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'localId': uid}),
      );

      client.close();

      if (response.statusCode != 200) {
        dev.log('Auth API Error: ${response.statusCode} - ${response.body}',
            name: 'DeleteUserService');
        GCPLog.error(
            'Failed to delete user from Firebase Auth.',
            error: response.body,
            userId: uid);
        return 'Failed to delete user account logic. External API returned: ${response.statusCode}';
      }

      dev.log('User $uid deleted from Firebase Auth successfully.', name: 'DeleteUserService');
      GCPLog.info('User Auth identity successfully deleted.', userId: uid);

      // 2. Perform Selective Booking Cleanup (Future Bookings Only)
      await _cleanupUserBookings(uid);

      // 3. Delete Associated User Profile Data
      final firestore = FirebaseFirestore.instance;
      await Future.wait([
        firestore.collection(FirebaseConstants.userName).doc(uid).delete(),
        firestore.collection(FirebaseConstants.allottedSlots).doc(uid).delete(),
        firestore.collection(FirebaseConstants.staffAccess).doc(uid).delete(),
      ]);

      dev.log('User collections removed for $uid', name: 'DeleteUserService');
      GCPLog.info('User profile collections removed.', userId: uid);

      return null; // Return null on success
    } catch (e, stackTrace) {
      dev.log('Exception in deleteUserCompletely: $e', error: e, stackTrace: stackTrace, name: 'DeleteUserService');
      GCPLog.error('Exception during user deletion process.', error: e, userId: uid);
      return e.toString();
    }
  }

  /// Cleans up only the FUTURE bookings for a user, retaining past bookings.
  static Future<void> _cleanupUserBookings(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    // Reset time to midnight for accurate date comparison
    final today = DateTime(now.year, now.month, now.day);
    final dateFormat = DateFormat('dd-MM-yyyy');
    final dbDateFormat = DateFormat('yyyy-MM-dd');

    try {
      final userBookingsSnapshot = await firestore
          .collection('bookingUserDetails')
          .doc(uid)
          .collection('bookings')
          .get();

      int deletedFutureBookings = 0;
      int retainedPastBookings = 0;

      for (var doc in userBookingsSnapshot.docs) {
        final data = doc.data();
        final bookingDateStr = data['date'] as String?;
        if (bookingDateStr == null) continue;

        try {
          final bookingDate = dateFormat.parse(bookingDateStr);
          
          if (bookingDate.isBefore(today)) {
            // It's in the past: retain it
            retainedPastBookings++;
            continue;
          }

          // It's today or in the future: delete it
          deletedFutureBookings++;
          final ticketId = doc.id;
          final hall = data['hall'] as String? ?? '2216-Hall';
          final slots = List<dynamic>.from(data['slots'] ?? []);

          // Restore Time Slots if 2216-Hall
          if (hall == '2216-Hall' || hall.isEmpty) {
            final formattedDbDate = dbDateFormat.format(bookingDate);
            final timeSlotsDoc = firestore
                .collection('timeSlots')
                .doc(formattedDbDate)
                .collection('availability')
                .doc('slots');

            final timeSlotSnapshot = await timeSlotsDoc.get();
            if (timeSlotSnapshot.exists) {
              final currentAvailability =
                  Map<String, dynamic>.from(timeSlotSnapshot.data()!);
              bool needsUpdate = false;
              for (var slot in slots) {
                if (slot is String && currentAvailability.containsKey(slot)) {
                  currentAvailability[slot] = true;
                  needsUpdate = true;
                }
              }
              if (needsUpdate) {
                await timeSlotsDoc.update(currentAvailability);
              }
            }
          }

          // Cleanup Global Booking Details Collection
          final globalBookingDoc = firestore
              .collection('bookingDetails')
              .doc(bookingDateStr)
              .collection('booking')
              .doc(ticketId);

          final globalSnapshot = await globalBookingDoc.get();
          if (globalSnapshot.exists) {
            final globalData = globalSnapshot.data() as Map<String, dynamic>;
            final globalSlots = List<dynamic>.from(globalData['slots'] ?? []);
            final remainingSlots =
                globalSlots.where((s) => !slots.contains(s)).toList();

            if (remainingSlots.isEmpty) {
              await globalBookingDoc.delete();
            } else {
              await globalBookingDoc.update({
                'slots': FieldValue.arrayRemove(slots),
              });
            }
          }

          // Delete the individual user's future booking ticket
          await doc.reference.delete();

        } catch (e) {
          dev.log('Error parsing or deleting booking date ($bookingDateStr): $e',
              name: 'DeleteUserService');
        }
      }

      dev.log(
          'Booking cleanup complete. Future bookings deleted: $deletedFutureBookings, Past bookings retained: $retainedPastBookings.',
          name: 'DeleteUserService');
      GCPLog.info(
        'Booking cleanup complete. Cleared $deletedFutureBookings future bookings, retained $retainedPastBookings past bookings.',
        userId: uid,
      );
    } catch (e) {
      dev.log('Exception during _cleanupUserBookings: $e', error: e, name: 'DeleteUserService');
      GCPLog.error('Failed to execute Selective Booking Cleanup.', error: e, userId: uid);
    }
  }
}
