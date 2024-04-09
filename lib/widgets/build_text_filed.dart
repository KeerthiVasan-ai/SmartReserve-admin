import "package:flutter/material.dart";

class BuildTextForm extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final Icon prefixIcon;
  final Function()? onTap;
  final double horizontalPadding;
  final double verticalPadding;

  const BuildTextForm(
      {super.key,
      required this.controller,
      required this.label,
      required this.readOnly,
      required this.prefixIcon,
      this.onTap,
      this.horizontalPadding = 25.0,
      this.verticalPadding = 4.0
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Enter $label";
          }
          return null;
        },
        controller: controller,
        onTap: onTap,
        autofocus: false,
        readOnly: readOnly,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: prefixIcon,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF124076))),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            labelStyle: const TextStyle(color: Color(0xFF124076))),
      ),
    );
  }
}
