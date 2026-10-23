// app/modules/privacy_policy/controllers/privacy_policy_controller.dart

import 'package:get/get.dart';

class PolicySection {
  final String titleKey;
  final String content;

  const PolicySection({
    required this.titleKey,
    required this.content,
  });
}

class PrivacyPolicyController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxInt selectedSectionIndex = 0.obs;

  final List<PolicySection> sections = const [
    PolicySection(
      titleKey: 'privacy_policy.terms_of_service',
      content:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since 1966, when designers at Letraset and James Mosley, the librarian at St Bride Printing Library in London, took a 1914 Cicero translation and scrambled it to make dummy text for Letraset\'s Body Type sheets.\n\nIt has survived not only many decades, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised thanks to these sheets and more recently with desktop publishing software like Aldus PageMaker and Microsoft Word including versions of Lorem Ipsum.',
    ),
    PolicySection(
      titleKey: 'privacy_policy.acceptable_use',
      content:
          'Acceptable Use policy defines the rules and restrictions for using our platform. Users must comply with all applicable laws and regulations while using our services. Any misuse of the platform may result in account suspension or termination.\n\nWe reserve the right to modify these policies at any time. Users will be notified of significant changes through the application or via email. Continued use of the service after changes constitutes acceptance of the new terms.',
    ),
    PolicySection(
      titleKey: 'privacy_policy.advertising_rules',
      content:
          'Our advertising rules govern how promotional content is displayed and managed on our platform. All advertisements must comply with our community guidelines and applicable advertising standards.\n\nAdvertisers are responsible for ensuring their content is accurate, non-deceptive, and appropriate for all audiences. We reserve the right to reject or remove any advertisement that violates our policies.',
    ),
    PolicySection(
      titleKey: 'privacy_policy.responsible_disclosure',
      content:
          'We take security seriously and appreciate the efforts of security researchers who help us maintain the integrity of our platform. If you discover a security vulnerability, please report it to our security team promptly.\n\nWe commit to acknowledging your report within 48 hours and working with you to understand and address the issue. We ask that you refrain from publicly disclosing the vulnerability until we have had a chance to resolve it.',
    ),
  ];

  void selectSection(int index) {
    selectedSectionIndex.value = index;
  }

  PolicySection get currentSection => sections[selectedSectionIndex.value];

  @override
  void onInit() {
    super.onInit();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading.value = false;
  }
}