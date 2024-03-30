import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_reserve_admin/screens/view_screen.dart';
import 'package:smart_reserve_admin/widgets/build_elevated_button.dart';
import 'package:smart_reserve_admin/widgets/build_text_filed.dart';
import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late TextEditingController myDate;

  @override
  void initState() {
    super.initState();
    myDate = TextEditingController();
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _selectDate() async {
    DateTime? picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 20)));

    if (picker != null) {
      setState(() {
        myDate.text = DateFormat('dd-MM-yyyy').format(picker).toString();
      });
    }
  }

  void displaySlots() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ViewScreen(selectedDate: myDate.text)));
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Smart Reserve - Admin",
            style: GoogleFonts.poppins(
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
    );
  }
}
