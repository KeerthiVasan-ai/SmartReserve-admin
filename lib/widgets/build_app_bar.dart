import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

AppBar buildAppBar(String title) {
  return AppBar(
    title: Text(
      title,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    backgroundColor: Colors.transparent,
    centerTitle: true,
    elevation: 0,
  );
}