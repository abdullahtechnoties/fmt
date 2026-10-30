import 'package:fmt/utilities/image_path_helper.dart';
import 'package:fmt/utilities/translation_extention.dart';

/// FMT customer from the Store App API.
///
/// Register/login return `{ token, user }` where user carries
/// `id, name, email, contact, alternate_number`. Profile endpoints add
/// avatar/city/district fields — all parsed defensively.
class UserModel {
  UserModel({
    this.id,
    this.name,
    this.email,
    this.contact,
    this.alternateNumber,
    this.city,
    this.district,
    this.address,
    this.avatar,
    this.createdAt,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? contact;
  final String? alternateNumber;
  final String? city;
  final String? district;
  final String? address;
  final String? avatar;
  final String? createdAt;

  String get displayName {
    final n = name?.trim() ?? '';
    if (n.isNotEmpty) return n;
    return 'profile.guest'.trns();
  }

  String get phoneDisplay => (contact?.trim().isNotEmpty ?? false)
      ? contact!.trim()
      : (alternateNumber?.trim() ?? '');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      contact: (json['contact'] ?? json['whatsapp'] ?? json['phone'])
          ?.toString(),
      alternateNumber: json['alternate_number']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      address: json['address']?.toString(),
      avatar: getImage(
        (json['avatar'] ?? json['profile_image'] ?? json['photo_path'])
            ?.toString(),
      ),
      createdAt: json['created_at']?.toString(),
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? contact,
    String? alternateNumber,
    String? city,
    String? district,
    String? address,
    String? avatar,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      alternateNumber: alternateNumber ?? this.alternateNumber,
      city: city ?? this.city,
      district: district ?? this.district,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
      'alternate_number': alternateNumber,
      'city': city,
      'district': district,
      'address': address,
      'avatar': avatar,
      'created_at': createdAt,
    };
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
