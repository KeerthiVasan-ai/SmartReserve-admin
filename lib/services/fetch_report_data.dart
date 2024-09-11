import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_reserve_admin/utils/file_storage.dart';
import '../view_model/generate_excel.dart';
import '../view_model/generate_pdf.dart';

class FetchReportData {
  final BuildContext context;

  FetchReportData(this.context);

  String loadingMessage = "Initiating";
  List<String> name = [];
  List<String> tokenNumber = [];
  List<String> courseCode = [];
  List<String> dateList = [];
  List<String> firstSlots = [];
  List<String> secondSlots = [];
  List<dynamic> allData = [];

  void fetchReportData(
      String fromDate, String toDate, String fileFormat) async {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Initiating $fileFormat Generation")));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    List<String> dates = createDateList(fromDate, toDate);
    for (var date in dates) {
      CollectionReference collectionRef = FirebaseFirestore.instance
          .collection('bookingDetails')
          .doc(date)
          .collection("booking");

      QuerySnapshot querySnapshot =
          await collectionRef.orderBy("slotKey").get();

      allData = querySnapshot.docs.map((doc) => doc.data()).toList();

      for (var data in allData) {
        name.add(data["name"]);
        tokenNumber.add(data["tokenNumber"]);
        courseCode.add(data["courseCode"]);
        dateList.add(data["date"]);
        firstSlots.add(data["slots"][0]);
        try {
          secondSlots.add(data["slots"][1]);
        } catch (ex) {
          secondSlots.add("");
        }
      }
    }

    try {
      if (fileFormat == "XLSX") {
        GenerateExcel(context).generateExcel(
            tokenNumber, name, courseCode, dateList, firstSlots, secondSlots);
      } else if (fileFormat == "PDF") {
        final pdfFile = await GeneratePDF().generatePdf(fromDate, toDate,
            tokenNumber, name, courseCode, dateList, firstSlots, secondSlots);
        FileStorage.openFile(pdfFile);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generated $fileFormat in Documents")));
      print(name.length);
    } catch (ex) {
      print(ex);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to Generate $fileFormat in Documents")));
    }
  }

  List<String> createDateList(String fromDateStr, String toDateStr) {
    DateTime fromDate = DateFormat('dd-MM-yyyy').parse(fromDateStr);
    DateTime toDate = DateFormat('dd-MM-yyyy').parse(toDateStr);

    List<String> dateList = [];

    int differenceInDays = toDate.difference(fromDate).inDays;

    for (int i = 0; i <= differenceInDays; i++) {
      DateTime currentDate = fromDate.add(Duration(days: i));
      dateList.add(DateFormat('dd-MM-yyyy').format(currentDate));
    }

    return dateList;
  }
}
