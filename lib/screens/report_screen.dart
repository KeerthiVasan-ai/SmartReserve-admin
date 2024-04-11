import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_reserve_admin/services/fetch_report_data.dart';
import 'package:smart_reserve_admin/widgets/build_alert_dialog.dart';
import 'package:smart_reserve_admin/widgets/build_app_bar.dart';
import 'package:smart_reserve_admin/widgets/build_drop_down_menu.dart';
import 'package:smart_reserve_admin/widgets/build_text_filed.dart';
import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

import '../utils/constants.dart';
import '../widgets/build_elevated_button.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _reportFormKey = GlobalKey<FormState>();
  late TextEditingController fromDate;
  late TextEditingController toDate;
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedFormat;

  _ReportScreenState() {
    _selectedFormat = Constants.reportFormat[0];
  }

  @override
  void initState() {
    fromDate = TextEditingController();
    toDate = TextEditingController();
    super.initState();
  }

  Future<void> _selectFromDate() async {
    DateTime? picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2024),
        lastDate: DateTime.now());

    if (picker != null) {
      setState(() {
        fromDate.text = DateFormat('dd-MM-yyyy').format(picker).toString();
      });
    }
  }

  Future<void> _selectToDate() async {
    DateTime? picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2024),
        lastDate: DateTime.now());

    if (picker != null) {
      setState(() {
        toDate.text = DateFormat('dd-MM-yyyy').format(picker).toString();
      });
    }
  }

  alert(TextEditingController password) {
    BuildDialog(context).showPasswordDialog(password);
  }

  void generateReport() {
    if (_reportFormKey.currentState!.validate()) {
      DateTime fromDateValue = DateFormat('dd-MM-yyyy').parse(fromDate.text);
      DateTime toDateValue = DateFormat('dd-MM-yyyy').parse(toDate.text);
      if (fromDateValue.isBefore(toDateValue)) {
        FetchReportData(context)
            .fetchReportData(fromDate.text, toDate.text, _selectedFormat!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Select the Legit Dates")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar("Report Generation"),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            alert(_passwordController);
          },
          child: const Icon(Icons.delete_forever),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                  child: Form(
                    key: _reportFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Generate Report",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: BuildTextForm(
                                controller: fromDate,
                                label: "From Date",
                                readOnly: true,
                                prefixIcon:
                                    const Icon(Icons.date_range_rounded),
                                onTap: _selectFromDate,
                                horizontalPadding: 15.0,
                                verticalPadding: 4.0,
                              ),
                            ),
                            Expanded(
                              child: BuildTextForm(
                                controller: toDate,
                                label: "To Date",
                                readOnly: true,
                                prefixIcon:
                                    const Icon(Icons.date_range_rounded),
                                onTap: _selectToDate,
                                horizontalPadding: 15.0,
                                verticalPadding: 4.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        BuildDropDownMenu(
                          selectedFormat: _selectedFormat!,
                          label: "Report Format",
                          prefixIcon: const Icon(Icons.file_present),
                          onChanged: (value) {
                            setState(() {
                              _selectedFormat = value; // Update selected value
                            });
                          },
                        ),
                        BuildElevatedButton(
                          actionOnButton: generateReport,
                          buttonText: "Generate!",
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
