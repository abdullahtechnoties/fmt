import 'dart:io';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MultipleImagePickerController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();

  final RxMap<int, File> attachedImages = <int, File>{}.obs;
  final RxInt currentEditingId = RxInt(-1);

  Future<void> pickImageFromGallery(int attachmentId) async {
    try {
      currentEditingId.value = attachmentId;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        if (file.path != null) {
          attachedImages[attachmentId] = File(file.path!);
          update();
          Get.back();
        }
      }
    } catch (e) {
      SnackbarService.showError(
        title: "errors.errorTitle".trns(),
        message: "errors.imagePickerGallery".trns(),
      );
    }
  }

  Future<void> pickImageFromCamera(int attachmentId) async {
    try {
      currentEditingId.value = attachmentId;
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedImage != null) {
        attachedImages[attachmentId] = File(pickedImage.path);
        update();
        Get.back();
      }
    } catch (e) {
      SnackbarService.showError(
        title: "errors.errorTitle".trns(),
        message: "errors.imagePickerCamera".trns(),
      );
    }
  }

  void removeImage(int attachmentId) {
    if (attachedImages.containsKey(attachmentId)) {
      attachedImages.remove(attachmentId);
    }
  }

  bool hasImage(int attachmentId) {
    return attachedImages.containsKey(attachmentId);
  }

  File? getImage(int attachmentId) {
    return attachedImages[attachmentId];
  }

  Map<int, File> get images => attachedImages;
}