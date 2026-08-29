import 'dart:convert';

import '../http/http_client.dart';
import '../identity/app_instance_identity.dart';
import 'ops_console_reporter.dart';

class HttpOpsConsoleReporter implements OpsConsoleReporter {
  HttpOpsConsoleReporter({
    required this.httpClient,
    required this.identity,
    required this.baseUrl,
  });

  final HttpClient httpClient;
  final AppInstanceIdentity identity;
  final String baseUrl;

  @override
  Future<void> heartbeat() async {
    if (baseUrl.trim().isEmpty) return;
    final uri = Uri.parse(baseUrl).resolve('v1/heartbeat');
    await httpClient.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'appId': identity.appId,
        'displayName': identity.displayName,
        'type': 'heartbeat',
      }),
    );
  }
}
