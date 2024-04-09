import "dart:developer" as dev;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import '../utils/file_storage.dart';

class GenerateExcel {
  final BuildContext context;
  
  GenerateExcel(this.context);
  
  void generateExcel(
      List<String> tokenNumber,
      List<String> name,
      List<String> courseCode,
      List<String> date,
      List<String> firstSlots,
      List<String> secondSlots) {

    final excel.Workbook workbook = excel.Workbook();
    final excel.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByIndex(1, 1).setText("S.No");
    sheet.getRangeByIndex(1, 2).setText("Token Number");
    sheet.getRangeByIndex(1, 3).setText("Name");
    sheet.getRangeByIndex(1, 4).setText("Course Code");
    sheet.getRangeByIndex(1, 5).setText("Date");
    sheet.getRangeByIndex(1, 6).setText("Slots");

    for (var i = 0; i < tokenNumber.length; i++) {
      sheet.getRangeByIndex(i + 2, 1).setText(i.toString());
      sheet.getRangeByIndex(i + 2, 2).setText(tokenNumber[i]);
      sheet.getRangeByIndex(i + 2, 3).setText(name[i]);
      sheet.getRangeByIndex(i + 2, 4).setText(courseCode[i]);
      sheet.getRangeByIndex(i + 2, 5).setText(date[i]);
      sheet
          .getRangeByIndex(i + 2, 6)
          .setText("${firstSlots[i]},${secondSlots[i]}");
    }

    final List<int> bytes = workbook.saveAsStream();
    FileStorage.writeCounter(Uint8List.fromList(bytes), "2216-Hall-Booking-Report.xlsx");
    dev.log("Success",name:"Log");

  }
}