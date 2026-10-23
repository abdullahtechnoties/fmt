import 'package:fmt/network/api/api_path.dart';

String? getImage(String? image) {
  final value = image?.trim();
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return value;
  }

  return '${ApiPath.imageUrl}/${value.replaceFirst(RegExp(r'^/+'), '')}';
}