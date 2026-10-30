import 'package:fmt/utilities/image_path_helper.dart';

/// A branch from `GET /stores` / `GET /bootstrap`.
/// Per API docs every field except [id]/[name]/[slug] can be null —
/// hide the row rather than rendering "null".
class StoreModel {
  StoreModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.address,
    this.phone1,
    this.phone2,
    this.whatsapp,
  });

  final int id;
  final String name;
  final String slug;
  final String? image;
  final String? address;
  final String? phone1;
  final String? phone2;
  final String? whatsapp;

  /// Display phone: first configured number wins.
  String? get displayPhone {
    for (final p in [phone1, phone2, whatsapp]) {
      if (p != null && p.trim().isNotEmpty) return p.trim();
    }
    return null;
  }

  bool get hasContact =>
      displayPhone != null || (address?.trim().isNotEmpty ?? false);

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: getImage(json['image']?.toString()),
      address: _nullIfEmpty(json['address']?.toString()),
      phone1: _nullIfEmpty(json['phone_1']?.toString()),
      phone2: _nullIfEmpty(json['phone_2']?.toString()),
      whatsapp: _nullIfEmpty(json['whatsapp']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'image': image,
        'address': address,
        'phone_1': phone1,
        'phone_2': phone2,
        'whatsapp': whatsapp,
      };
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

String? _nullIfEmpty(String? v) {
  final t = v?.trim();
  return (t == null || t.isEmpty || t.toLowerCase() == 'null') ? null : t;
}
