import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:smart_reserve_admin/widgets/build_app_bar.dart";

import "../services/fetch_user_booking.dart";

class ViewScreen extends StatelessWidget {
  ViewScreen({super.key,required this.selectedDate});

  String selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar("Booked Slots"),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background/check2.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: StreamBuilder(
            stream: FetchUserBooking.fetchBookingDetails(selectedDate),
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

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.bookmark),
                            const SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${data['tokenNumber']}"),
                                Text("${data['name']}"),
                                Text("${data['date']}"),
                                Text("Slots: ${data['slots'].join(', ')}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

