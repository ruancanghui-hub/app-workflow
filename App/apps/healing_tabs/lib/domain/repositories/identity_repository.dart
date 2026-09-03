import '../models/local_account.dart';

abstract class IdentityRepository {
  /// 确保本机已有设备身份；首次调用时生成并持久化。
  Future<LocalAccount> ensureLocalAccount();

  Future<LocalAccount> currentAccount();

  Future<LocalAccount> updateDisplayName(String name);
}
