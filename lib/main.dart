import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_reserve_admin/firebase_options.dart';
import 'package:smart_reserve_admin/screens/splash_screen.dart';
import 'package:smart_reserve_admin/services/gcp_credentials.dart';
import 'package:smart_reserve_admin/services/gcp_logging_service.dart';
import 'package:smart_reserve_admin/services/native_update_service.dart';
import 'package:smart_reserve_admin/services/local_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background processing
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.init();
  
  // Setup FCM listeners and permissions
  await _setupFCM();

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  await GCPCredentials.instance.load();
  await GCPLog.instance.setupLoggingApi();
  GCPLog.info('Admin Application started and logging initialized');

  if (Platform.isAndroid) {
    NativeUpdateService.checkForUpdate();
  }

  runApp(const MyApp());
}

Future<void> _setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Set the background messaging handler early on
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 1. Request permissions (specifically for Android 13+)
  try {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    GCPLog.info(
      'Notification permission status: ${settings.authorizationStatus}',
    );
  } catch (e) {
    GCPLog.error('Failed to request notification permissions', error: e);
  }

  // 2. Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    GCPLog.info('FCM message received in foreground: ${message.messageId}');
    if (message.notification != null) {
      LocalNotificationService.showImmediateNotification(
        title: message.notification!.title ?? 'Smart Reserve Alert',
        body: message.notification!.body ?? '',
      );
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Reserve Admin",
      home: SplashScreen(),
    );
  }
}
