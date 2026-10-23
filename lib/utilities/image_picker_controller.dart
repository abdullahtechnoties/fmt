import 'dart:io';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        selectedImage.value = File(pickedImage.path);
        Get.back();
      }
    } catch (e) {
      SnackbarService.showError(
        title: "errors.errorTitle".trns(),
        message: "errors.imagePickerGallery".trns(),
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        selectedImage.value = File(pickedImage.path);
        Get.back();
      }
    } catch (e) {
      SnackbarService.showError(
        title: "errors.errorTitle".trns(),
        message: "errors.imagePickerCamera".trns(),
      );
    }
  }

  void clearImage() {
    selectedImage.value = null;
  }
}