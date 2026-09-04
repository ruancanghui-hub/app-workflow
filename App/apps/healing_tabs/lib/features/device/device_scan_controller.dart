import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

import '../../data/ble/yc_ble_ring_service.dart';
import 'device_connection_controller.dart';

class DeviceScanController extends GetxController {
  DeviceScanController({
    required YcBleRingService ble,
    required DeviceConnectionController connection,
  })  : _ble = ble,
        _connection = connection;

  final YcBleRingService _ble;
  final DeviceConnectionController _connection;

  final devices = <BluetoothDevice>[].obs;
  final isScanning = false.obs;
  final isConnecting = false.obs;
  final connectingId = ''.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(startScan());
  }

  @override
  void onClose() {
    unawaited(_ble.stopScan());
    super.onClose();
  }

  Future<void> startScan() async {
    if (isScanning.value || isConnecting.value) return;
    errorMessage.value = '';
    isScanning.value = true;
    try {
      await _ble.ensureInitialized();
      final list = await _ble.scanDevices(time: 6);
      devices.assignAll(list);
      if (list.isEmpty) {
        errorMessage.value = '未发现附近设备，请靠近戒指后点刷新';
      }
    } catch (e, st) {
      debugPrint('scan failed: $e\n$st');
      errorMessage.value = e is StateError ? e.message : '扫描失败，请检查蓝牙权限';
      devices.clear();
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectAt(int index) async {
    if (isConnecting.value) return;
    if (index < 0 || index >= devices.length) return;
    final device = devices[index];
    final id = device.deviceIdentifier.isNotEmpty
        ? device.deviceIdentifier
        : device.macAddress;
    isConnecting.value = true;
    connectingId.value = id;
    errorMessage.value = '';
    try {
      await _connection.pairWith(device);
      Get.back<void>();
    } catch (e, st) {
      debugPrint('connect failed: $e\n$st');
      errorMessage.value = '连接失败，请重试';
      Get.snackbar(
        '连接失败',
        '请确认戒指已开机并靠近手机',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xEE123049),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isConnecting.value = false;
      connectingId.value = '';
    }
  }
}
