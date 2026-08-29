import 'package:healing_tabs/core/identity/app_instance_identity.dart';
import 'package:healing_tabs/core/ops_console/ops_console_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FakeOpsConsoleReporter records heartbeat with identity', () async {
    const identity = AppInstanceIdentity(appId: 'a1', displayName: 'Demo');
    final reporter = FakeOpsConsoleReporter(identity);
    await reporter.heartbeat();
    expect(reporter.heartbeats.single.appId, 'a1');
  });
}
