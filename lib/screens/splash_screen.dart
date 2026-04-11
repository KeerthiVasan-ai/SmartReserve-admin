import "dart:async";

import "package:flutter/material.dart";

import "package:smart_reserve_admin/widgets/ui/background_shapes.dart";
import "package:smart_reserve_admin/screens/app_blocked_screen.dart";
import "package:smart_reserve_admin/services/fetch_server.dart";
import "package:smart_reserve_admin/utils/constants.dart";

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
    _checkAppStatus();
  }

  void _checkAppStatus() async {
    final serverDetails = await FetchServerDetails.checkIsAppUnderMaintenance();

    final bool isUnderMaintenance =
        serverDetails['isAppUnderMaintenance'] as bool;
    final String version = serverDetails['version'] as String;
    final List allowedAdminVersions =
        serverDetails['allowedAdminVersions'] as List;

    if (isUnderMaintenance) {
      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AppBlockedScreen(state: AppBlockState.underMaintenance),
          ),
        ),
      );
    } else if (!allowedAdminVersions.contains(Constants.APP_VERSION)) {
      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AppBlockedScreen(
              state: AppBlockState.updateRequired,
              version: version,
            ),
          ),
        ),
      );
    } else {
      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Auth()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Smart Reserve - Admin",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0),
                ),
                Text(
                  "v${Constants.APP_VERSION}-STABLE",
                  style: TextStyle(
                      fontFamily: 'FiraSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
