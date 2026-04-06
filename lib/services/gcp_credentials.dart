import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

/// Shared GCP service-account credentials loaded once from the bundled JSON
/// asset.  [GCPLog] consumes this instead of duplicating the raw key material
/// in source code.
class GCPCredentials {
  GCPCredentials._();
  static final GCPCredentials instance = GCPCredentials._();

  Map<String, dynamic>? _json;
  bool _isLoaded = false;

  /// The raw JSON map read from `assets/service-account.json`.
  Map<String, dynamic> get json {
    assert(_isLoaded, 'Call GCPCredentials.instance.load() before accessing json');
    return _json!;
  }

  /// The GCP project ID extracted from the credentials.
  String get projectId => _json?['project_id'] ?? '';

  /// Loads and caches the credential file.  Safe to call multiple times.
  Future<void> load() async {
    if (_isLoaded) return;
    try {
      final raw = await rootBundle.loadString('assets/service-account.json');
      _json = jsonDecode(raw) as Map<String, dynamic>;
      _isLoaded = true;
      dev.log('Service-account credentials loaded', name: 'GCPCredentials');
    } catch (e) {
      dev.log('Failed to load service-account.json: $e', name: 'GCPCredentials');
      rethrow;
    }
  }

  /// Convenience: creates [ServiceAccountCredentials] from the cached JSON.
  ServiceAccountCredentials get serviceAccountCredentials =>
      ServiceAccountCredentials.fromJson(json);
}
