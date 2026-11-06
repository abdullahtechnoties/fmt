import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/support_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/support_repository.dart';
import 'package:fmt/utilities/auth_guard.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// Tracked support form (`GET /support/categories`, `POST /support/tickets`).
/// Login-only: guests get a prompt, never a form that would 401. Name and
/// email prefill from the account but are stored on the ticket itself.
class SupportController extends GetxController {
  SupportController({SupportRepository? supportRepo})
      : _supportRepo = supportRepo ?? SupportRepository();

  final SupportRepository _supportRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final issueController = TextEditingController();

  final RxList<SupportCategory> categories = <SupportCategory>[].obs;
  final selectedCategoryName = RxnString();
  final isLoadingCategories = true.obs;
  final isSubmitting = false.obs;
  final RxnString loadError = RxnString();

  /// Global badge for the "My tickets" button (`GET /support/unread`).
  final unreadCount = 0.obs;

  /// Resolves the dropdown's category name back to its server id.
  int? get selectedCategoryId {
    final name = selectedCategoryName.value;
    if (name == null) return null;
    for (final c in categories) {
      if (c.name == name) {
        if (c.id is int) return c.id as int;
        return int.tryParse('${c.id}');
      }
    }
    return null;
  }

  bool get isLoggedIn => AuthGuard.isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn) {
      _prefillFromAccount();
      loadCategories();
      refreshUnread();
    } else {
      isLoadingCategories.value = false;
    }
  }

  void _prefillFromAccount() {
    try {
      final user = Get.find<AuthService>().currentUser.value;
      if ((nameController.text).isEmpty) {
        nameController.text = (user?.name ?? '').toString();
      }
      if ((emailController.text).isEmpty) {
        emailController.text = (user?.email ?? '').toString();
      }
    } catch (_) {}
  }

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    loadError.value = null;
    try {
      final res = await _supportRepo.categories();
      if (res.isError || res.data == null) {
        loadError.value = (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'support.load_failed'.trns();
        return;
      }
      categories.assignAll(res.data!);
      if (selectedCategoryName.value != null &&
          res.data!.every(
              (c) => c.name != selectedCategoryName.value)) {
        selectedCategoryName.value = null;
      }
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> refreshUnread() async {
    if (!isLoggedIn) {
      unreadCount.value = 0;
      return;
    }
    try {
      final counts = await _supportRepo.unread();
      unreadCount.value = counts.unread;
    } catch (_) {}
  }

  String? requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'support.field_required'.trns();
    }
    return null;
  }

  String? emailValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'support.field_required'.trns();
    }
    if (!GetUtils.isEmail(value!.trim())) {
      return 'support.email_invalid'.trns();
    }
    return null;
  }

  Future<void> submitTicket() async {
    if (isSubmitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedCategoryId == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'support.category_required'.trns(),
      );
      return;
    }
    isSubmitting.value = true;
    try {
      final res = await _supportRepo.raise(
        categoryId: selectedCategoryId,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        subject: subjectController.text.trim(),
        message: issueController.text.trim(),
      );
      if (res.isError || res.data == null) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'support.raise_failed'.trns(),
        );
        return;
      }
      final ticket = res.data!;
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: 'support.raise_success'.trnsFormat(
            {'reference': ticket.reference}),
      );
      subjectController.clear();
      issueController.clear();
      selectedCategoryName.value = null;
      refreshUnread();
      // The new ticket carries its reference — open the thread directly.
      if (ticket.reference.isNotEmpty) {
        Get.toNamed(Routes.TICKET_DETAILS,
            arguments: ticket.reference);
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> goToTickets() async {
    final allowed = await AuthGuard.requireLogin(
      title: 'auth.required_title'.trns(),
      message: 'auth.required_chat'.trns(),
    );
    if (!allowed) return;
    await Get.toNamed(Routes.TICKETS);
    refreshUnread();
  }

  Future<void> goToLogin() async {
    await AuthGuard.requireLogin(
      title: 'auth.required_title'.trns(),
      message: 'support.login_prompt'.trns(),
    );
    if (isLoggedIn) {
      _prefillFromAccount();
      loadCategories();
      refreshUnread();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    issueController.dispose();
    super.onClose();
  }
}
