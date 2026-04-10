import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:intl/intl.dart';
import 'package:smart_reserve_admin/screens/create_user_screen.dart';
import 'package:smart_reserve_admin/screens/view_screen.dart';
import 'package:smart_reserve_admin/widgets/app_drawer.dart';
import 'package:smart_reserve_admin/widgets/build_elevated_button.dart';
import 'package:smart_reserve_admin/widgets/build_text_filed.dart';
import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController myDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    myDate = TextEditingController();
    _subscribeToAdminNotifications();
  }

  void _subscribeToAdminNotifications() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('admin_notifications');
      dev.log('Subscribed to admin_notifications topic', name: 'MainScreen');
    } catch (e) {
      dev.log('FCM subscription failed: $e', name: 'MainScreen');
    }
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _selectDate() async {
    DateTime? picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picker != null) {
      setState(() {
        myDate.text = DateFormat('dd-MM-yyyy').format(picker).toString();
      });
    }
  }

  void _navigateToCreateUser() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CreateUserScreen()));
  }

  void displaySlots() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewScreen(selectedDate: myDate.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: AppDrawer(scaffoldKey: _scaffoldKey),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: _navigateToCreateUser,
          child: const Icon(
            Icons.person_add_rounded,
            color: Colors.black,
          ),
        ),
        appBar: AppBar(
          title: Text(
            "Smart Reserve - Admin",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: _signOut,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.black,
                )),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BuildTextForm(
                  controller: myDate,
                  label: "Select the Date",
                  readOnly: true,
                  prefixIcon: const Icon(Icons.date_range_rounded),
                  onTap: _selectDate,
                ),
                BuildElevatedButton(
                    actionOnButton: displaySlots, buttonText: "CHECK!")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
