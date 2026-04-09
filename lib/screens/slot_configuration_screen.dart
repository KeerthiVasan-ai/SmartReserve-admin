import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_reserve_admin/services/gcp_logging_service.dart';
import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

class SlotConfigurationScreen extends StatefulWidget {
  const SlotConfigurationScreen({super.key});

  @override
  State<SlotConfigurationScreen> createState() =>
      _SlotConfigurationScreenState();
}

class _SlotConfigurationScreenState extends State<SlotConfigurationScreen> {
  final DocumentReference _configRef = FirebaseFirestore.instance
      .collection('slotConfigurations')
      .doc('globalSlots');

  Future<void> _toggleSlotDialog(
      String slotName, bool currentStatus, String currentReason) async {
    // If we're enabling it, we don't strictly need a reason, but if we're disabling, we do.
    bool newStatus = !currentStatus;
    TextEditingController reasonController =
        TextEditingController(text: newStatus ? '' : currentReason);

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            newStatus ? 'Enable $slotName' : 'Disable $slotName',
            style: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                newStatus
                    ? 'Are you sure you want to re-enable this slot?'
                    : 'Disabling this slot globally blocks it from all future scheduling. Please provide a reason.',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
              if (!newStatus) const SizedBox(height: 16),
              if (!newStatus)
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for disabling',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(newStatus ? 'Enable' : 'Disable',
                  style: TextStyle(
                      color: newStatus ? const Color(0xFF2D9596) : Colors.red,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      String updatedReason = newStatus ? '' : reasonController.text.trim();
      try {
        await _configRef.set({
          slotName: {'enabled': newStatus, 'reason': updatedReason}
        }, SetOptions(merge: true));

        GCPLog.info('Slot $slotName updated. Enabled: $newStatus, Reason: $updatedReason');
      } catch (e) {
        GCPLog.error('Failed to update slot $slotName', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update slot: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Global Slot Configuration",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _configRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            Map<String, dynamic> dbData = {};
            if (snapshot.hasData && snapshot.data!.exists) {
              dbData = snapshot.data!.data() as Map<String, dynamic>;
            }

            final List<String> dynamicSlotNames = dbData.keys.toList();

            dynamicSlotNames.sort((a, b) {
              final aOrder = (dbData[a] as Map?)?['order'] ?? 99;
              final bOrder = (dbData[b] as Map?)?['order'] ?? 99;
              return (aOrder as num).compareTo(bOrder as num);
            });

            if (dynamicSlotNames.isEmpty) {
              return Center(
                child: Text(
                  'No slots configured in Firebase.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: dynamicSlotNames.length,
              itemBuilder: (context, index) {
                final slotName = dynamicSlotNames[index];
                final slotConfig = dbData[slotName] as Map<String, dynamic>? ??
                    {'enabled': true, 'reason': ''};

                final bool isEnabled = slotConfig['enabled'] ?? true;
                final String reason = slotConfig['reason'] ?? '';

                final statusColor =
                    isEnabled ? const Color(0xFF2D9596) : const Color(0xFFE57373);

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      slotName,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          isEnabled ? 'Configured: Enabled' : 'Configured: Disabled',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!isEnabled && reason.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Reason: $reason',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.redAccent,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Switch(
                      value: isEnabled,
                      onChanged: (bool val) =>
                          _toggleSlotDialog(slotName, isEnabled, reason),
                      activeThumbColor: const Color(0xFF2D9596),
                      activeTrackColor:
                          const Color(0xFF2D9596).withValues(alpha: 0.40),
                      inactiveThumbColor: Colors.redAccent,
                      inactiveTrackColor: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
