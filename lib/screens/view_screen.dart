import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:smart_reserve_admin/widgets/build_app_bar.dart";
import "package:smart_reserve_admin/widgets/build_list_builder.dart";
import "package:smart_reserve_admin/widgets/ui/background_shapes.dart";

import "../services/fetch_user_booking.dart";

class ViewScreen extends StatefulWidget {
  ViewScreen({super.key,required this.selectedDate});

  String selectedDate;

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar("Booked Slots"),
        body: SafeArea(
          child: StreamBuilder(
            stream: FetchUserBooking.fetchBookingDetails(widget.selectedDate),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No Booking available.'),
                );
              }

              return BuildListBuilder(bookings: snapshot.data!.docs.toList(),);
            },
          ),
        ),
      ),
    );
  }
}

