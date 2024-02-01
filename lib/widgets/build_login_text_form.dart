import "package:flutter/material.dart";

class BuildLoginTextForm extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final bool obscureText;
  final Function()? onTap;

  const BuildLoginTextForm(
      {super.key,
        required this.controller,
        required this.label,
        required this.readOnly,
        required this.obscureText,
        this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextFormField(
            validator: (value){
              if(value == null || value.isEmpty){
                return "Enter $label";
              }
              return null;
            },
            controller: controller,
            obscureText: obscureText,
            onTap: onTap,
            autofocus: false,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
