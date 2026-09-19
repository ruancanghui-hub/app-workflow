import 'package:get/get.dart';

import '../../core/ops/analytics.dart';
import '../../core/ops/app_events.dart';
import '../../core/ops/jank_monitor.dart';
import '../../core/storage/key_value_store.dart';
import 'catalog_controller.dart';

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CatalogController(
        appEvents: Get.find<AppEvents>(),
        analytics: Get.find<Analytics>(),
        jankMonitor: Get.find<JankMonitor>(),
        store: Get.find<KeyValueStore>(),
      ),
      fenix: true,
    );
  }
}
