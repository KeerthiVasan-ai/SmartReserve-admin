import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:smart_reserve_admin/services/gcp_logging_service.dart';

class NativeUpdateService {
  static const MethodChannel _channel = MethodChannel('smart_reserve_admin/in_app_update');

  /// Checks for any available updates on the Play Store for the Admin app.
  /// If an update is available, it triggers the native IMMEDIATE update UI.
  static Future<void> checkForUpdate() async {
    try {
      dev.log('Initiating native update check (Admin)...', name: 'NativeUpdateService');
      final String? result = await _channel.invokeMethod('checkForUpdate');
      dev.log('Update check result (Admin): $result', name: 'NativeUpdateService');
      GCPLog.info('Native in-app update check (Admin): $result');
    } on PlatformException catch (e) {
      dev.log('Native update check failed (Admin): ${e.message}', name: 'NativeUpdateService');
      
      if (e.code == 'UPDATE_CANCELED') {
        GCPLog.warning('Admin user canceled the mandatory in-app update');
      } else if (e.code == 'UPDATE_ERROR') {
        GCPLog.error('Error during native in-app update check (Admin)', error: e.message);
      } else {
        GCPLog.info('Native update status (Admin): ${e.code} - ${e.message}');
      }
    } catch (e) {
      dev.log('Unexpected error during update check (Admin): $e', name: 'NativeUpdateService');
      GCPLog.error('Unexpected error in NativeUpdateService (Admin)', error: e);
    }
  }
}
