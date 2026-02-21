import 'package:intl/intl.dart';

class Constants {
  static const universityName = "ANNAMALAI UNIVERSITY";
  static const facultyName = "Faculty of Engineering and Technology";
  static const deptName = "Dept. of Computer Science and Engineering";
  static const appName = "Smart Reserve";
  static const appDescription = "App Developed by CSE Dept.";
  static const copyright = "Smart Reserve © Dept of CSE, FEAT, AU";
  static String date =
      DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();
  static String time =
      DateFormat.Hms().format(DateTime.now()).toString().replaceAll(":", "-");

  static String fileContent = "$date-$time";
  static List<String> reportFormat = ["PDF", "XLSX"];

  // App version & maintenance
  static const APP_VERSION = '1.3.0';
  static const UNDER_MAINTENANCE =
      "The App is Currently Under Maintenance. \n Sorry for the Inconvenience";
  static const NEW_VERSION_AVAILABLE = "Update Available";
  static const APP_URL =
      "https://github.com/KeerthiVasan-ai/SmartReserve-admin/releases/tag/v";
}
