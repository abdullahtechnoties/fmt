import 'package:fmt/utilities/translation_extention.dart';
import '../utilities/image_path_helper.dart';

class UserModel {
  UserModel({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.gender,
    this.dob,
    this.nationalityId,
    this.profileImage,
    this.countryId,
    this.stateId,
    this.cityId,
    this.areaId,
    this.ethnicityId,
    this.educationId,
    this.occupationId,
    this.bodyTypeId,
    this.height,
    this.heightUnit,
    this.weight,
    this.weightUnit,
    this.hairColourId,
    this.eyeColourId,
    this.skinColourId,
    this.religionId,
    this.sectId,
    this.prayerFrequencyId,
    this.dressCodeId,
    this.dietaryPreferenceId,
    this.maritalStatusId,
    this.maritalStatusDurationYears,
    this.hasChildren,
    this.wantChildren,
    this.partnerMaritalStatusId,
    this.ageMin,
    this.ageMax,
    this.distanceRange,
    this.partnerReligionId,
    this.partnerEthnicityId,
    this.partnerSectId,
    this.partnerOccupationId,
    this.partnerEducationId,
    this.zipCode,
    this.longitude,
    this.latitude,
    this.facebook,
    this.skype,
    this.linkedin,
    this.twitter,
    this.whatsapp,
    this.instagram,
    this.occupation,
    this.description,
    this.nic,
    this.nicFront,
    this.nicBack,
    this.isActive,
    this.emailVerifiedAt,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.roles,
    this.loyaltyPoints,
  });

  final int? id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? gender;
  final String? dob;
  final int? nationalityId;
  final String? profileImage;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final int? areaId;
  final int? ethnicityId;
  final int? educationId;
  final int? occupationId;
  final int? bodyTypeId;
  final String? height;
  final String? heightUnit;
  final String? weight;
  final String? weightUnit;
  final int? hairColourId;
  final int? eyeColourId;
  final int? skinColourId;
  final int? religionId;
  final int? sectId;
  final int? prayerFrequencyId;
  final int? dressCodeId;
  final int? dietaryPreferenceId;
  final int? maritalStatusId;
  final int? maritalStatusDurationYears;
  final String? hasChildren;
  final String? wantChildren;
  final int? partnerMaritalStatusId;
  final int? ageMin;
  final int? ageMax;
  final int? distanceRange;
  final int? partnerReligionId;
  final int? partnerEthnicityId;
  final int? partnerSectId;
  final int? partnerOccupationId;
  final int? partnerEducationId;
  final String? zipCode;
  final String? facebook;
  final String? skype;
  final String? linkedin;
  final String? twitter;
  final String? whatsapp;
  final String? instagram;
  final String? occupation;
  final String? description;
  final String? nic;
  final String? nicFront;
  final String? nicBack;
  final int? isActive;
  final String? address;
  final String? longitude;
  final String? latitude;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final List<Role>? roles;
  final int? loyaltyPoints;

  String get displayName =>
      (fullName.trim().isNotEmpty) ? fullName.trim() : 'user.handyman'.trns();

  String get fullName {
    final combined = [firstName, lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ')
        .trim();
    if (combined.isNotEmpty) return combined;
    return name?.trim() ?? '';
  }

  bool get hasBasicDetails =>
      firstName != null &&
      firstName!.trim().isNotEmpty &&
      lastName != null &&
      lastName!.trim().isNotEmpty &&
      gender != null &&
      gender!.trim().isNotEmpty &&
      dob != null &&
      dob!.trim().isNotEmpty &&
      nationalityId != null &&
      countryId != null &&
      stateId != null &&
      cityId != null &&
      areaId != null &&
      ethnicityId != null &&
      educationId != null &&
      occupationId != null;

  bool get hasCompletedProfile =>
      hasBasicDetails &&
      religionId != null &&
      sectId != null &&
      bodyTypeId != null;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesJson = json['roles'];
    final roles = rolesJson is List
        ? rolesJson
              .whereType<Map>()
              .map(
                (roleJson) =>
                    Role.fromJson(Map<String, dynamic>.from(roleJson)),
              )
              .toList()
        : _roleFromValue(json['role']);

    return UserModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      nationalityId: _parseInt(json['nationality_id']),
      profileImage: getImage(
        json['profile_image']?.toString() ?? json['photo_path']?.toString(),
      ),
      loyaltyPoints: _parseInt(json['loyalty_points']),
      countryId: _parseInt(json['country_id']),
      stateId: _parseInt(json['state_id']),
      cityId: _parseInt(json['city_id']),
      areaId: _parseInt(json['area_id']),
      ethnicityId: _parseInt(json['ethnicity_id']),
      educationId: _parseInt(json['education_id']),
      occupationId: _parseInt(json['occupation_id']),
      bodyTypeId: _parseInt(json['body_type_id']),
      height: json['height']?.toString(),
      heightUnit: json['height_unit']?.toString(),
      weight: json['weight']?.toString(),
      weightUnit: json['weight_unit']?.toString(),
      hairColourId: _parseInt(json['hair_colour_id']),
      eyeColourId: _parseInt(json['eye_colour_id']),
      skinColourId: _parseInt(json['skin_colour_id']),
      religionId: _parseInt(json['religion_id']),
      sectId: _parseInt(json['sect_id']),
      prayerFrequencyId: _parseInt(json['prayer_frequency_id']),
      dressCodeId: _parseInt(json['dress_code_id']),
      dietaryPreferenceId: _parseInt(json['dietary_preference_id']),
      maritalStatusId: _parseInt(json['marital_status_id']),
      maritalStatusDurationYears: _parseInt(
        json['marital_status_duration_years'],
      ),
      hasChildren: json['has_children']?.toString(),
      wantChildren: json['want_children']?.toString(),
      partnerMaritalStatusId: _parseInt(json['partner_marital_status_id']),
      ageMin: _parseInt(json['age_min']),
      ageMax: _parseInt(json['age_max']),
      distanceRange: _parseInt(json['distance_range']),
      partnerReligionId: _parseInt(json['partner_religion_id']),
      partnerEthnicityId: _parseInt(json['partner_ethnicity_id']),
      partnerSectId: _parseInt(json['partner_sect_id']),
      partnerOccupationId: _parseInt(json['partner_occupation_id']),
      partnerEducationId: _parseInt(json['partner_education_id']),
      zipCode: json['zip_code']?.toString(),
      facebook: json['facebook']?.toString(),
      longitude: json['longitude'] as String?,
      latitude: json['latitude'] as String?,
      skype: json['skype']?.toString(),
      linkedin: json['linkedin']?.toString(),
      twitter: json['twitter']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      instagram: json['instagram']?.toString(),
      occupation: json['occupation_id']?.toString(),
      description: json['description']?.toString(),
      nic: json['nic']?.toString(),
      nicFront: getImage(json['nic_f']?.toString()),
      nicBack: getImage(json['nic_b']?.toString()),
      isActive: json['is_active'],
      address: json['address']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'nationality_id': _parseInt(nationalityId),
      'photo_path': getImage(profileImage),
      'profile_image': getImage(profileImage),
      'loyalty_points': loyaltyPoints,
      'country_id': _parseInt(countryId),
      'state_id': _parseInt(stateId),
      'city_id': _parseInt(cityId),
      'area_id': _parseInt(areaId),
      'ethnicity_id': _parseInt(ethnicityId),
      'education_id': _parseInt(educationId),
      'occupation_id': _parseInt(occupationId),
      'body_type_id': _parseInt(bodyTypeId),
      'height': height,
      'height_unit': heightUnit,
      'weight': weight,
      'weight_unit': weightUnit,
      'hair_colour_id': _parseInt(hairColourId),
      'eye_colour_id': _parseInt(eyeColourId),
      'skin_colour_id': _parseInt(skinColourId),
      'religion_id': _parseInt(religionId),
      'sect_id': _parseInt(sectId),
      'prayer_frequency_id': _parseInt(prayerFrequencyId),
      'dress_code_id': _parseInt(dressCodeId),
      'dietary_preference_id': _parseInt(dietaryPreferenceId),
      'marital_status_id': _parseInt(maritalStatusId),
      'marital_status_duration_years': _parseInt(maritalStatusDurationYears),
      'has_children': hasChildren,
      'want_children': wantChildren,
      'partner_marital_status_id': _parseInt(partnerMaritalStatusId),
      'age_min': _parseInt(ageMin),
      'age_max': _parseInt(ageMax),
      'distance_range': _parseInt(distanceRange),
      'partner_religion_id': _parseInt(partnerReligionId),
      'partner_ethnicity_id': _parseInt(partnerEthnicityId),
      'partner_sect_id': _parseInt(partnerSectId),
      'partner_occupation_id': _parseInt(partnerOccupationId),
      'partner_education_id': _parseInt(partnerEducationId),
      'zip_code': zipCode,
      'longitude': longitude,
      'latitude': latitude,
      'facebook': facebook,
      'skype': skype,
      'linkedin': linkedin,
      'twitter': twitter,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'occupation': occupation,
      'description': description,
      'address': address,
      'nic': nic,
      'nic_f': getImage(nicFront),
      'nic_b': getImage(nicBack),
      'is_active': isActive,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'roles': roles?.map((role) => role.toJson()).toList(),
    };
  }
}

class Role {
  Role({
    this.id,
    this.name,
    this.guardName,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  final int? id;
  final String? name;
  final String? guardName;
  final String? createdAt;
  final String? updatedAt;
  final Pivot? pivot;

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      guardName: json['guard_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      pivot: json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'pivot': pivot?.toJson(),
    };
  }
}

class Pivot {
  Pivot({this.modelType, this.modelId, this.roleId});

  final String? modelType;
  final int? modelId;
  final int? roleId;

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      modelType: json['model_type']?.toString(),
      modelId: json['model_id'] as int?,
      roleId: json['role_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'model_type': modelType, 'model_id': modelId, 'role_id': roleId};
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<Role>? _roleFromValue(dynamic value) {
  final roleName = value?.toString().trim();
  if (roleName == null || roleName.isEmpty) return null;
  return [Role(name: roleName)];
}
