import "package:flutter/material.dart";

class BuildTextForm extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final Icon prefixIcon;
  final Function()? onTap;

  const BuildTextForm(
      {super.key,
        required this.controller,
        required this.label,
        required this.readOnly,
        required this.prefixIcon,
        this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 4.0),
      child: TextFormField(
        validator: (value){
          if(value == null || value.isEmpty){
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
                borderSide: BorderSide(color: Color(0xFF124076))
            ),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black)
            ),
            labelStyle: const TextStyle(color: Color(0xFF124076))
        ),
      ),
    );
  }
}
