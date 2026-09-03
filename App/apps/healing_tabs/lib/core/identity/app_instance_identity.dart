class AppInstanceIdentity {
  const AppInstanceIdentity({
    required this.appId,
    required this.displayName,
  });

  final String appId;
  final String displayName;
}

abstract class AppInstanceIdentityReader {
  AppInstanceIdentity read();
}

class DefineAppInstanceIdentityReader implements AppInstanceIdentityReader {
  const DefineAppInstanceIdentityReader();

  static const _appId = String.fromEnvironment(
    'APP_INSTANCE_ID',
    defaultValue: 'yunyao_local',
  );
  static const _displayName = String.fromEnvironment(
    'APP_INSTANCE_NAME',
    defaultValue: '云遥',
  );

  @override
  AppInstanceIdentity read() => const AppInstanceIdentity(
        appId: _appId,
        displayName: _displayName,
      );
}

class FakeAppInstanceIdentityReader implements AppInstanceIdentityReader {
  FakeAppInstanceIdentityReader(this.identity);

  final AppInstanceIdentity identity;

  @override
  AppInstanceIdentity read() => identity;
}
