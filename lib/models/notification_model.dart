class SlotNotification {
  final String notificationId;
  final String requestedBy;
  final String requestedTo;
  final String requestedByName;
  final String requestedToName;
  final String bookingId;
  final String slotInfo;
  final String date;
  final String status;
  final String type;
  final String notificationInitiatedAt;

  SlotNotification({
    this.notificationId = '',
    this.requestedBy = '',
    this.requestedTo = '',
    this.requestedByName = '',
    this.requestedToName = '',
    this.bookingId = '',
    this.slotInfo = '',
    this.date = '',
    this.status = 'pending',
    this.type = 'booking',
    this.notificationInitiatedAt = '',
  });

  factory SlotNotification.fromJson(Map<String, dynamic> json) {
    return SlotNotification(
      notificationId: json['notificationId'] ?? '',
      requestedBy: json['requestedBy'] ?? '',
      requestedTo: json['requestedTo'] ?? '',
      requestedByName: json['requestedByName'] ?? '',
      requestedToName: json['requestedToName'] ?? '',
      bookingId: json['bookingId'] ?? '',
      slotInfo: json['slotInfo'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'pending',
      type: json['type'] ?? 'booking',
      notificationInitiatedAt: json['notificationInitiatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'requestedBy': requestedBy,
      'requestedTo': requestedTo,
      'requestedByName': requestedByName,
      'requestedToName': requestedToName,
      'bookingId': bookingId,
      'slotInfo': slotInfo,
      'date': date,
      'status': status,
      'type': type,
      'notificationInitiatedAt': notificationInitiatedAt,
    };
  }
}
