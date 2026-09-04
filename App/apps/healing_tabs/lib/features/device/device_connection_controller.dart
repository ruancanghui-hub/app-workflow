import 'package:get/get.dart';

import '../../domain/models/device_content.dart';
import '../../domain/repositories/device_repository.dart';
import '../tabs/device/device_content_catalog.dart';

class DeviceConnectionController extends GetxController {
  DeviceConnectionController({required DeviceRepository deviceRepository})
      : _deviceRepository = deviceRepository;

  final DeviceRepository _deviceRepository;
  final paired = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPairedState();
  }

  bool get isPaired => paired.value;

  DeviceDaySnapshot get snapshot => paired.value
      ? DeviceContentCatalog.pairedSnapshot
      : DeviceContentCatalog.unpairedSnapshot;

  Future<void> loadPairedState() async {
    paired.value = await _deviceRepository.isPaired();
  }

  Future<void> pair() async {
    await _deviceRepository.setPaired(true);
    paired.value = true;
  }

  Future<void> unpairDemo() async {
    await _deviceRepository.setPaired(false);
    paired.value = false;
  }
}
