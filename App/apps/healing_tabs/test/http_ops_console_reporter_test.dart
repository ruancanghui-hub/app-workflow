import 'dart:convert';

import 'package:healing_tabs/core/http/http_client.dart';
import 'package:healing_tabs/core/identity/app_instance_identity.dart';
import 'package:healing_tabs/core/ops_console/http_ops_console_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HttpOpsConsoleReporter posts heartbeat JSON with appId', () async {
    late Uri seenUrl;
    late Object? seenBody;
    final http = FakeHttpClient(
      postHandler: (url, headers, body) async {
        seenUrl = url;
        seenBody = body;
        return HttpResponse(statusCode: 204, body: '');
      },
    );
    final reporter = HttpOpsConsoleReporter(
      httpClient: http,
      identity: const AppInstanceIdentity(appId: 'app_1', displayName: 'Demo'),
      baseUrl: 'https://ops.example.com/',
    );

    await reporter.heartbeat();

    expect(seenUrl.toString(), 'https://ops.example.com/v1/heartbeat');
    final decoded = jsonDecode(seenBody! as String) as Map<String, dynamic>;
    expect(decoded['appId'], 'app_1');
    expect(decoded['type'], 'heartbeat');
  });

  test('HttpOpsConsoleReporter no-ops when baseUrl empty', () async {
    final http = FakeHttpClient();
    final reporter = HttpOpsConsoleReporter(
      httpClient: http,
      identity: const AppInstanceIdentity(appId: 'app_1', displayName: 'Demo'),
      baseUrl: '',
    );
    await reporter.heartbeat();
    expect(http.calls, isEmpty);
  });
}
