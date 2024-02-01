import "dart:async";

import "package:flutter/material.dart";

import "../services/auth.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3),
            ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const Auth()))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCF2F1),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFDCF2F1),

          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Smart Reserve - Admin",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24.0),),
                Text("v1.0.0 - STABLE"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
