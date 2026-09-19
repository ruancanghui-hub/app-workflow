import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/ops/app_events.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/ui/ui.dart';
import '../../l10n/app_localizations.dart';

class FeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => FeedbackController(appEvents: Get.find<AppEvents>()),
      fenix: true,
    );
  }
}

class FeedbackController extends GetxController {
  FeedbackController({required this.appEvents});

  final AppEvents appEvents;
  final message = ''.obs;
  final submitting = false.obs;

  late final TextEditingController textController;

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController();
    textController.addListener(() => message.value = textController.text);
    appEvents.screenView('feedback');
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  bool get canSubmit => message.value.trim().isNotEmpty && !submitting.value;

  Future<void> submit() async {
    if (!canSubmit) return;
    submitting.value = true;
    await appEvents.feedbackSubmit(length: message.value.trim().length);
    message.value = '';
    textController.clear();
    submitting.value = false;
  }
}

class FeedbackPage extends GetView<FeedbackController> {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = FTheme.of(context);

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.feedbackTitle),
        prefixes: [
          FHeaderAction.back(onPress: Get.back),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.all(tokens.spaceMd),
        children: [
          Text(
            l10n.feedbackHint,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          FTextField(
            control: FTextFieldControl.managed(
              controller: controller.textController,
            ),
            label: Text(l10n.feedbackMessageLabel),
            hint: l10n.feedbackMessageHint,
            maxLines: 6,
            minLines: 4,
          ),
          SizedBox(height: tokens.spaceLg),
          Obx(
            () => AppButton(
              loading: controller.submitting.value,
              onPress: controller.canSubmit
                  ? () async {
                      await controller.submit();
                      if (!context.mounted) return;
                      AppToast.success(context, l10n.feedbackSubmitted);
                      Get.back();
                    }
                  : null,
              child: Text(l10n.feedbackSubmit),
            ),
          ),
        ],
      ),
    );
  }
}
