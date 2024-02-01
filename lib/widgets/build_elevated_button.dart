import "package:flutter/material.dart";

class BuildElevatedButton extends StatelessWidget {
  final Function() actionOnButton;
  final String buttonText;

  const BuildElevatedButton(
      {super.key, required this.actionOnButton, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: ElevatedButton(
        onPressed: actionOnButton,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        child: Text(
          buttonText.toUpperCase(),
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ),
    );
  }
}
