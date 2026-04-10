import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_reserve_admin/services/local_notification_service.dart';
import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = false;
  List<TimeOfDay> _notificationTimes = [const TimeOfDay(hour: 22, minute: 0)];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = prefs.getBool('enableNotifications') ?? false;
      List<String>? times = prefs.getStringList('notificationTimes');
      if (times != null) {
        _notificationTimes = times.map((t) {
          final parts = t.split(':');
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList();
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', _enableNotifications);
    await prefs.setStringList(
      'notificationTimes',
      _notificationTimes.map((t) => '${t.hour}:${t.minute}').toList(),
    );

    // Update notifications
    await LocalNotificationService.cancelAllNotifications();
    if (_enableNotifications) {
      for (int i = 0; i < _notificationTimes.length; i++) {
        final time = _notificationTimes[i];
        await LocalNotificationService.scheduleDailyNotification(
          id: i,
          title: 'Slot Configuration Reminder',
          body: 'Don\'t forget to configure slots for tomorrow!',
          hour: time.hour,
          minute: time.minute,
        );
      }
    }
  }

  Future<void> _addTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 22, minute: 0),
    );
    if (picked != null && !_notificationTimes.contains(picked)) {
      setState(() {
        _notificationTimes.add(picked);
      });
      _saveSettings();
    }
  }

  void _removeTime(int index) {
    setState(() {
      _notificationTimes.removeAt(index);
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingCard(
              title: "Daily Reminders",
              subtitle: "Notify me to configure slots for tomorrow",
              trailing: Switch(
                value: _enableNotifications,
                onChanged: (val) {
                  setState(() {
                    _enableNotifications = val;
                  });
                  _saveSettings();
                },
                activeColor: const Color(0xFF2D9596),
              ),
            ),
            if (_enableNotifications) ...[
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Reminder Times",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ..._notificationTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      time.format(context),
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _removeTime(index),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addTime,
                icon: const Icon(Icons.add, color: Color(0xFF2D9596)),
                label: const Text(
                  "Add Reminder Time",
                  style: TextStyle(color: Color(0xFF2D9596), fontFamily: 'Poppins'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}
