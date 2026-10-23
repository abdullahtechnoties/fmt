import 'package:fmt/app/data/language_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/services/translation_service.dart';
import 'package:get/get.dart';

class LanguagesController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString locale = "".obs;
  final RxList<LanguagesData> languagesList = <LanguagesData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialLocale();
    _initLanguages();
  }

  Future<void> _loadInitialLocale() async {
    final saved = await AuthService.getSavedLocale();
    locale.value = saved ?? 'en';
  }

  void _initLanguages() {
    languagesList.assignAll([
      LanguagesData(
        id: 1,
        name: 'English',
        locale: 'en',
        isRtl: 0,
        isDefault: 1,
        status: 1,
      ),
      LanguagesData(
        id: 2,
        name: 'اردو',
        locale: 'ur',
        isRtl: 1,
        isDefault: 0,
        status: 1,
      ),
      LanguagesData(
        id: 3,
        name: 'العربية',
        locale: 'ar',
        isRtl: 1,
        isDefault: 0,
        status: 1,
      ),
    ]);
  }

  Future<void> changeLanguage(String selectedLocale) async {
    locale.value = selectedLocale;
    await AuthService.saveLocale(selectedLocale);
    await TranslationService.to.loadTranslations(selectedLocale);
  }
}
