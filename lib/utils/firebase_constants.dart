/// Centralized Firestore collection name constants.
/// Use these instead of hardcoded strings to avoid typos
/// and make collection name changes easy.
class FirebaseConstants {
  FirebaseConstants._(); // Prevent instantiation

  // Collection names
  static const String bookingDetails = 'bookingDetails';
  static const String booking = 'booking';
  static const String constants = 'constants';
  static const String allottedSlots = 'allottedSlots';
  static const String userName = 'userName';

  static const String staffId = 'tokenNumber';
  static const String staffAccess = 'staffaccess';

  // Document names
  static const String server = 'server';
}
