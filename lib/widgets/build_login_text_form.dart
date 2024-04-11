import "package:flutter/material.dart";

class BuildLoginTextForm extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  bool obscureText;
  final bool isPassword;
  final Function()? onTap;

  BuildLoginTextForm(
      {super.key,
      required this.controller,
      required this.label,
      required this.readOnly,
      required this.obscureText,
      required this.isPassword,
      this.onTap});

  @override
  State<BuildLoginTextForm> createState() => _BuildLoginTextFormState();
}

class _BuildLoginTextFormState extends State<BuildLoginTextForm> {
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter ${widget.label}";
              }
              return null;
            },
            controller: widget.controller,
            obscureText: widget.obscureText,
            onTap: widget.onTap,
            autofocus: false,
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              hintText: widget.label,
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.obscureText = !widget.obscureText;
                        });
                      },
                      child: Icon(
                        widget.obscureText
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    )
                  : null,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
