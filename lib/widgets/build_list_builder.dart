import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:smart_reserve_admin/widgets/ui/frosted_glass.dart';

class BuildListBuilder extends StatelessWidget {
  final List<DocumentSnapshot> bookings;

  const BuildListBuilder({required this.bookings, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        var data = bookings[index].data() as Map<String, dynamic>;
        final String hall = data['hall'] is String ? data['hall'] : '2216-Hall';

        return FrostedGlassUI(
          theHeight: 110.0,
          theWidth: 200.0,
          theChild: Stack(
            children: [
              Padding(
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
                          "${data['name']}",
                          style: TextStyle(
                              fontFamily: 'EBGaramond',
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          "${data['courseCode']}",
                          style: TextStyle(
                              fontFamily: 'EBGaramond',
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text("${data['date']}",
                            style: TextStyle(
                                fontFamily: 'EBGaramond',
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text("Slots: ${data['slots'].join(', ')}",
                            style: TextStyle(
                                fontFamily: 'EBGaramond',
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF124076).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF124076).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    hall,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF124076),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
