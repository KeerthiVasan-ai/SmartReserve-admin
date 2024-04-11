import 'package:flutter/material.dart';
import 'package:smart_reserve_admin/utils/constants.dart';

class BuildDropDownMenu extends StatefulWidget {
  String selectedFormat;
  String label;
  Icon prefixIcon;
  Function(String) onChanged;

  BuildDropDownMenu({
    required this.selectedFormat,
    required this.label,
    required this.prefixIcon,
    required this.onChanged,
    super.key,
  });

  @override
  State<BuildDropDownMenu> createState() => _BuildDropDownMenuState();
}

class _BuildDropDownMenuState extends State<BuildDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: DropdownButtonFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Enter ${widget.label}";
          }
          return null;
        },
        value: widget.selectedFormat,
        items: Constants.reportFormat
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          setState(() {
            widget.onChanged(val.toString());
          });
        },
        icon: const Icon(Icons.arrow_drop_down_circle),
        decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: widget.prefixIcon,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF124076))),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            labelStyle: const TextStyle(color: Color(0xFF124076))),
      ),
    );
  }
}
