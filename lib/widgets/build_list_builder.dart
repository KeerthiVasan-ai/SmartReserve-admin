import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_reserve_admin/widgets/ui/frosted_glass.dart';


class BuildListBuilder extends StatelessWidget {
  final List<DocumentSnapshot> bookings;

  const BuildListBuilder(
      {required this.bookings,
        super.key});


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        var data = bookings[index].data() as Map<String, dynamic>;
        return FrostedGlassUI(
          theHeight: 110.0,
          theWidth: 200.0,
          theChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.bookmark),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['tokenNumber']}",
                      style: GoogleFonts.ebGaramond(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "${data['courseCode']}",
                      style: GoogleFonts.ebGaramond(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text("${data['date']}",
                        style: GoogleFonts.ebGaramond(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Slots: ${data['slots'].join(', ')}",
                        style: GoogleFonts.ebGaramond(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
