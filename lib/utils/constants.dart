import 'package:intl/intl.dart';

class Constants {
  static const universityName = "ANNAMALAI UNIVERSITY";
  static const facultyName = "Faculty of Engineering and Technology";
  static const deptName = "Dept. of Computer Science and Engineering";
  static const appName = "Smart Reserve";
  static const appDescription = "App Developed by CSE Dept.";
  static const copyright = "Smart Reserve © Dept of CSE, FEAT, AU";
  static String date = DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();
  static String time = DateFormat.Hm().format(DateTime.now());
  static String fileContent = "$date - $time";

  static List<String> reportFormat = ["PDF","XLSX"];

}