import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:googleapis/logging/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:smart_reserve_admin/utils/constants.dart';
import 'package:smart_reserve_admin/services/gcp_credentials.dart';

/// Google Cloud Logging singleton.
///
/// Usage:
///   await GCPLog.instance.setupLoggingApi();   // call once at startup
///   GCPLog.info('Report generated', userId: uid);
///   GCPLog.error('User creation failed', error: e, stacktrace: st);
class GCPLog {
  GCPLog._();
  static final GCPLog instance = GCPLog._();

  LoggingApi? _loggingApi;
  bool _isSetup = false;
  String _projectId = '';

  /// Authenticates with GCP and initialises the Logging API.
  Future<void> setupLoggingApi() async {
    if (_isSetup) return;

    try {
      final creds = GCPCredentials.instance;
      _projectId = creds.projectId;

      final authClient = await clientViaServiceAccount(
        creds.serviceAccountCredentials,
        [LoggingApi.loggingWriteScope],
      );

      _loggingApi = LoggingApi(authClient);
      _isSetup = true;
      dev.log('Cloud Logging API setup for $_projectId', name: 'GCPLog');
    } catch (error) {
      dev.log('Error setting up Cloud Logging API: $error', name: 'GCPLog');
    }
  }
  static void info(String message, {String? userId}) =>
      instance._write(level: 'INFO', message: message, userId: userId);

  static void warning(String message, {String? userId}) =>
      instance._write(level: 'WARNING', message: message, userId: userId);

  static void error(
    String message, {
    Object? error,
    StackTrace? stacktrace,
    String? userId,
  }) => instance._write(
    level: 'ERROR',
    message: message,
    errorString: error?.toString(),
    stacktrace: stacktrace?.toString(),
    userId: userId,
  );

  static void debug(String message, {String? userId}) =>
      instance._write(level: 'DEBUG', message: message, userId: userId);

  void _write({
    required String level,
    required String message,
    String? errorString,
    String? stacktrace,
    String? userId,
  }) {
    // Always log locally so the debug console still works.
    dev.log('[$level] $message', name: 'GCPLog');

    if (!_isSetup || _loggingApi == null) return;

    final appMode = kReleaseMode ? 'release' : 'debug';
    final logName = 'projects/$_projectId/logs/$appMode-production';

    final resource = MonitoredResource()..type = 'global';

    final Map<String, Object?> payload = {'message': message};
    if (level == 'ERROR') {
      payload['exception'] = errorString ?? 'Unidentified Exception';
      payload['stack_trace'] = stacktrace ?? '';
    }

    final logEntry = LogEntry()
      ..logName = logName
      ..jsonPayload = payload
      ..resource = resource
      ..severity = level
      ..labels = {
        'project_id': _projectId,
        'level': level.toUpperCase(),
        'app_mode': appMode,
        'user_id': userId ?? 'unknown',
        'app_version': Constants.APP_VERSION,
        'platform': Platform.isAndroid ? 'ANDROID' : 'IOS',
        'app_name': 'SmartReserve-Admin',
      };

    final request = WriteLogEntriesRequest()..entries = [logEntry];

    _loggingApi!.entries.write(request).catchError((dynamic e) {
      dev.log('Error writing log entry: $e', name: 'GCPLog');
      return WriteLogEntriesResponse();
    });
  }
}
