import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:smart_reserve_admin/services/fetch_server.dart";

import "../services/delete_booking.dart";
import "build_text_filed.dart";

class BuildDialog {
  final BuildContext context;

  BuildDialog(this.context);

  Future<void> showPasswordDialog(TextEditingController password) async {
    final currentPassword = await FetchServerDetails.fetchPwd();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Alert !!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Sensitive Operation ! Are you sure want to delete all the booking details ?",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Enter the Admin Password",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                BuildTextForm(
                  controller: password,
                  label: "Password",
                  readOnly: false,
                  prefixIcon: const Icon(Icons.password),
                  horizontalPadding: 0.0,
                  verticalPadding: 0.0,
                ),
                const SizedBox(height: 10.0,),
                Text(
                  "Hint : Take a Report Before Deleting",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                password.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (password.text == currentPassword) {
                  await DeleteBooking.deleteBookingDetails(
                      "bookingDetails", "booking");
                  await DeleteBooking.deleteBookingDetails(
                      "bookingUserDetails", "bookings");
                  Navigator.of(context).pop();
                  password.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('All Data Deleted Successfully'),
                  ));
                } else {
                  password.clear();

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Incorrect password.'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
