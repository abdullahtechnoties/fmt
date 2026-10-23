import 'package:fmt/services/translation_service.dart';

extension TranslationsExtension on String {
  String trns() => TranslationService.to.get(this);

  String trnsFormat(Map<String, dynamic> variables) =>
      TranslationService.to.format(this, variables);
}
