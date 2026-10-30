import 'package:flutter/material.dart';
import 'package:fmt/models/account_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/account_repository.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// My Profile: renders the live account (`GET /account/profile`) with the
/// saved billing block (`GET /account/addresses`).
///
/// Profile fields save via `PUT /account/profile`; the billing section saves
/// via `PUT /account/addresses/billing`. Email is the login identifier and
/// stays read-only. There is no avatar upload endpoint, so the header keeps
/// the initial placeholder.
class EditProfileController extends GetxController {
  EditProfileController({AccountRepository? accountRepo})
      : _accountRepo = accountRepo ?? AccountRepository();

  final AccountRepository _accountRepo;

  final isLoading = true.obs;
  final isSavingProfile = false.obs;
  final isSavingBilling = false.obs;
  final RxnString loadError = RxnString();

  final formKey = GlobalKey<FormState>();

  // Profile fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final alternateController = TextEditingController();

  // Billing address fields (required: name, address, city, zip, country)
  final billingNameController = TextEditingController();
  final billingPhoneController = TextEditingController();
  final billingAddressController = TextEditingController();
  final billingCityController = TextEditingController();
  final billingZipController = TextEditingController();
  final billingCountryController = TextEditingController();

  AuthService get _auth => Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    billingCountryController.text = 'Pakistan';
    loadAccount();
  }

  Future<void> loadAccount() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final profileRes = await _accountRepo.profile();
      if (profileRes.isError || profileRes.data == null) {
        // Fall back to the cached session so the screen still renders.
        _fillFromSession();
        loadError.value = (profileRes.message?.isNotEmpty ?? false)
            ? profileRes.message
            : 'profile_edit.load_failed'.trns();
        return;
      }
      final user = profileRes.data!;
      nameController.text = user.name ?? '';
      emailController.text = user.email ?? '';
      phoneController.text = user.contact ?? '';
      alternateController.text = user.alternateNumber ?? '';

      final addressRes = await _accountRepo.addresses();
      final saved = addressRes.data;
      if (saved != null) _fillBilling(saved);
    } finally {
      isLoading.value = false;
    }
  }

  void _fillFromSession() {
    final user = _auth.currentUser.value;
    if (user == null) return;
    nameController.text = user.name ?? '';
    emailController.text = user.email ?? '';
    phoneController.text = user.contact ?? '';
    alternateController.text = user.alternateNumber ?? '';
  }

  void _fillBilling(CustomerAddress saved) {
    if ((saved.name ?? '').isNotEmpty) {
      billingNameController.text = saved.name!;
    } else if (billingNameController.text.isEmpty) {
      billingNameController.text = nameController.text;
    }
    if ((saved.phone ?? '').isNotEmpty) {
      billingPhoneController.text = saved.phone!;
    } else if (billingPhoneController.text.isEmpty) {
      billingPhoneController.text = phoneController.text;
    }
    billingAddressController.text = saved.address ?? '';
    billingCityController.text = saved.city ?? '';
    billingZipController.text = saved.zip ?? '';
    if ((saved.country ?? '').isNotEmpty) {
      billingCountryController.text = saved.country!;
    }
  }

  String? requiredValidator(String? v) {
    if ((v ?? '').trim().isEmpty) {
      return 'auth.validation.required'.trns();
    }
    return null;
  }

  String? phoneValidator(String? v) {
    if (((v ?? '').trim()).length < 7) {
      return 'auth.validation.phoneInvalid'.trns();
    }
    return null;
  }

  Future<void> saveProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSavingProfile.value) return;
    isSavingProfile.value = true;
    try {
      final res = await _accountRepo.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        contact: phoneController.text.trim(),
        alternateNumber: alternateController.text.trim().isEmpty
            ? null
            : alternateController.text.trim(),
      );
      if (res.isError) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'profile_edit.save_failed'.trns(),
        );
        return;
      }
      // Keep the cached session in sync (preserve email/avatar).
      final current = _auth.currentUser.value;
      final updated = res.data;
      if (current != null && updated != null) {
        await _auth.setCurrentUser(current.copyWith(
          name: updated.name ?? current.name,
          contact: updated.contact ?? current.contact,
          alternateNumber:
              updated.alternateNumber ?? current.alternateNumber,
        ));
      }
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'profile_edit.saved'.trns(),
      );
    } finally {
      isSavingProfile.value = false;
    }
  }

  Future<void> saveBilling() async {
    if (isSavingBilling.value) return;
    for (final c in [
      billingNameController,
      billingAddressController,
      billingCityController,
      billingZipController,
      billingCountryController,
    ]) {
      if (c.text.trim().isEmpty) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: 'profile_edit.billing_incomplete'.trns(),
        );
        return;
      }
    }
    isSavingBilling.value = true;
    try {
      final res = await _accountRepo.updateBilling(
        name: billingNameController.text.trim(),
        address: billingAddressController.text.trim(),
        city: billingCityController.text.trim(),
        zip: billingZipController.text.trim(),
        country: billingCountryController.text.trim(),
        phone: billingPhoneController.text.trim(),
      );
      if (res.isError) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'profile_edit.billing_failed'.trns(),
        );
        return;
      }
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'profile_edit.billing_saved'.trns(),
      );
    } finally {
      isSavingBilling.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    alternateController.dispose();
    billingNameController.dispose();
    billingPhoneController.dispose();
    billingAddressController.dispose();
    billingCityController.dispose();
    billingZipController.dispose();
    billingCountryController.dispose();
    super.onClose();
  }
}
