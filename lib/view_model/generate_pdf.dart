import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:smart_reserve_admin/utils/constants.dart';
import 'package:smart_reserve_admin/utils/file_storage.dart';

class GeneratePDF {
  Future<File> generatePdf(String fromDate,
      String toDate,
      List<String> tokenNumber,
      List<String> name,
      List<String> courseName,
      List<String> dateList,
      List<String> firstSlot,
      List<String> secondSlot,) async {
    final pdf = Document();
    final ByteData bytes = await rootBundle.load('assets/logo/dept_logo.png');
    final Uint8List byteList = bytes.buffer.asUint8List();
    pdf.addPage(MultiPage(
      build: (context) =>
      [
        buildHeader(byteList, fromDate, toDate),
        buildBookingDetails(
          tokenNumber,
          name,
          courseName,
          dateList,
          firstSlot,
          secondSlot,
        )
      ],
      footer: (context) => buildFooter(),
    ));

    return FileStorage.writeCounter(await pdf.save(), "2216-Hall-Booking-Report-${Constants.fileContent}.pdf");
  }

  static Widget buildHeader(Uint8List byteImage, String fromDate,
      String toDate) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildUniversityDetails(Constants.universityName,
                  Constants.facultyName, Constants.deptName),
              Container(
                height: 100,
                width: 100,
                child: Image(MemoryImage(byteImage), fit: BoxFit.cover),
              ),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("BOOKING REPORT",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ]),
          SizedBox(height: 2 * PdfPageFormat.mm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildDisplayText("From Date :", fromDate),
              buildDisplayText("To Date :", toDate),
            ],
          ),
          SizedBox(height: 10.0),
        ],
      );

  static Widget buildUniversityDetails(String universityName,
      String facultyName, String deptName) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(universityName, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(facultyName),
          Text(deptName),
        ],
      );

  static Widget buildDisplayText(String dateType, String date) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateType, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(date),
        ],
      );

  static Widget buildTitle(String title, String desc) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          SizedBox(height: 10.0),
          Text(desc),
        ],);

  static Widget buildBookingDetails(List<String> tokenNumber,
      List<String> name,
      List<String> courseName,
      List<String> dateList,
      List<String> firstSlot,
      List<String> secondSlot,) {
    final header = ["S. No", 'Token No.', "Name", "Course", "Date", "Slots"];
    final List<List<String>> data = [];
    for (int i = 0; i < tokenNumber.length; i++) {
      List<String> values = [
        "${i+1}",
        tokenNumber[i],
        name[i],
        courseName[i],
        dateList[i],
        "${firstSlot[i]},\n${secondSlot[i]}"
      ];
      data.add(values);
    }

    return TableHelper.fromTextArray(
        headers: header,
        data: data,
        border: null,
        headerStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellStyle: TextStyle(font: Font.times(), fontSize: 10.0),
        cellHeight: 30,
        headerAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.center,
          2: Alignment.center,
          3: Alignment.center,
          4: Alignment.center,
          5: Alignment.center,
          6: Alignment.center,
        },
        cellAlignments: {
          1: Alignment.center,
          3: Alignment.center,
        });
  }

  static Widget buildFooter() =>
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Divider(),
        SizedBox(height: 2 * PdfPageFormat.mm),
        buildDisplayText("Report Generated on :",
            DateFormat("dd-MM-yyyy").format(
                DateTime.now()).toString()),
        buildDisplayText(Constants.copyright, "")
      ]);
}
