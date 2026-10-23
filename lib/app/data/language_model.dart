class LanguagesModel {
  bool? status;
  List<LanguagesData>? data;

  LanguagesModel({this.status, this.data});

  LanguagesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <LanguagesData>[];
      json['data'].forEach((v) {
        data!.add(LanguagesData.fromJson(v));
      });
    }
  }
}

class LanguagesData {
  int? id;
  String? flag;
  String? name;
  String? locale;
  int? isRtl;
  int? isDefault;
  int? status;
  String? createdAt;
  String? updatedAt;

  LanguagesData({
    this.id,
    this.flag,
    this.name,
    this.locale,
    this.isRtl,
    this.isDefault,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  LanguagesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    flag = json['flag'];
    name = json['name'];
    locale = json['locale'];
    isRtl = json['is_rtl'];
    isDefault = json['is_default'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}