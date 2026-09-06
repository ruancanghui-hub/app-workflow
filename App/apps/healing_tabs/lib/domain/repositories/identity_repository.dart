import '../models/local_account.dart';

abstract class IdentityRepository {
  /// 确保本机已有设备身份；首次调用时生成并持久化。
  Future<LocalAccount> ensureLocalAccount();

  Future<LocalAccount> currentAccount();

  Future<LocalAccount> updateDisplayName(String name);

  /// 删除本机云遥账号及关联本地数据（睡眠、收藏、设备、心率、同意等）。
  Future<void> deleteLocalAccountAndData();
}
