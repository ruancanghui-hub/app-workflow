import 'package:get/get.dart';

import '../../core/env/app_environment.dart';
import '../../core/ops/diagnostics_access.dart';

class HomeController extends GetxController {
  HomeController({required this.environment});

  final AppEnvironment environment;
  final titleTapDetector = SecretTapDetector();

  String get variantLabel => environment.variant.name;
}
