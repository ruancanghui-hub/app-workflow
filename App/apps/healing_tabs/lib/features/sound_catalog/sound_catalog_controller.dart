import 'package:get/get.dart';

import '../../domain/models/sound_asset.dart';
import '../../domain/repositories/sound_repository.dart';

class SoundCatalogController extends GetxController {
  SoundCatalogController(this._repository);

  final SoundRepository _repository;

  final sounds = <SoundAsset>[].obs;
  final isLoading = true.obs;
  final error = RxnString();
  final serverAudioTotal = RxnInt();
  final serverAudioFetched = RxnInt();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      sounds.assignAll(await _repository.listAll());
      serverAudioTotal.value = _repository.serverAudioTotal;
      serverAudioFetched.value = _repository.serverAudioFetched;
    } catch (_) {
      error.value = '声景加载失败';
    } finally {
      isLoading.value = false;
    }
  }

  List<SoundAsset> get featured =>
      sounds.where((s) => s.isFeatured || s.isFree).take(3).toList();
}
