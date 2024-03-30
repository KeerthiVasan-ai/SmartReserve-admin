import "package:flutter/material.dart";
import 'dart:ui';

class FrostedGlassUI extends StatelessWidget {
  final double theWidth;
  final double theHeight;
  final Widget theChild;

  const FrostedGlassUI(
      {required this.theWidth,
        required this.theHeight,
        required this.theChild,
        super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: theWidth,
          height: theHeight,
          color: Colors.transparent,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.70)),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.30),
                        Colors.white.withOpacity(0.10)
                      ]),
                ),
              ),
              Center(
                child: theChild,
              )
            ],
          ),
        ),
      ),
    );
  }
}
