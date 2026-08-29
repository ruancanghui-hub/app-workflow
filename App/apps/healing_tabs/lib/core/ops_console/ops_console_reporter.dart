import '../identity/app_instance_identity.dart';

abstract class OpsConsoleReporter {
  Future<void> heartbeat();
}

class FakeOpsConsoleReporter implements OpsConsoleReporter {
  FakeOpsConsoleReporter(this.identity);

  final AppInstanceIdentity identity;
  final heartbeats = <AppInstanceIdentity>[];

  @override
  Future<void> heartbeat() async {
    heartbeats.add(identity);
  }
}
