import 'package:fmt/models/store_model.dart';
import 'package:fmt/utilities/image_path_helper.dart';

/// Payload of `GET /bootstrap`: branch list, site details, WhatsApp numbers,
/// currency and version flags. Cached so first paint works offline.
class BootstrapData {
  BootstrapData({
    this.stores = const [],
    this.defaultStoreId,
    this.currency = 'PKR',
    this.currencySymbol = 'Rs',
    this.siteName,
    this.siteLogo,
    this.sitePhone,
    this.siteEmail,
    this.topBarText,
    this.whatsappGeneral,
    this.whatsappOrder,
    this.minVersion,
    this.latestVersion,
    this.maintenance = false,
  });

  final List<StoreModel> stores;
  final int? defaultStoreId;
  final String currency;
  final String currencySymbol;
  final String? siteName;
  final String? siteLogo;
  final String? sitePhone;
  final String? siteEmail;
  final String? topBarText;
  final String? whatsappGeneral;
  final String? whatsappOrder;
  final String? minVersion;
  final String? latestVersion;
  final bool maintenance;

  StoreModel? storeById(int id) {
    for (final s in stores) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Preselect the `online-delivery` branch when present, else first active.
  int? get preselectedStoreId {
    if (defaultStoreId != null) return defaultStoreId;
    if (stores.isEmpty) return null;
    for (final s in stores) {
      if (s.slug == 'online-delivery') return s.id;
    }
    return stores.first.id;
  }

  factory BootstrapData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final app =
        data['app'] is Map ? Map<String, dynamic>.from(data['app']) : null;
    final site =
        data['site'] is Map ? Map<String, dynamic>.from(data['site']) : null;
    final wa = data['whatsapp'] is Map
        ? Map<String, dynamic>.from(data['whatsapp'])
        : null;
    final rawStores = data['stores'];
    return BootstrapData(
      stores: rawStores is List
          ? rawStores
              .whereType<Map>()
              .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      defaultStoreId: _parseInt(data['default_store_id']),
      currency: app?['currency']?.toString() ?? 'PKR',
      currencySymbol: app?['currency_symbol']?.toString() ?? 'Rs',
      siteName: site?['name']?.toString(),
      siteLogo: getImage(site?['logo']?.toString()),
      sitePhone: site?['phone']?.toString(),
      siteEmail: site?['email']?.toString(),
      topBarText: site?['top_bar_text']?.toString(),
      whatsappGeneral: wa?['general']?.toString(),
      whatsappOrder: wa?['order']?.toString(),
      minVersion: app?['min_version']?.toString(),
      latestVersion: app?['latest_version']?.toString(),
      maintenance: app?['maintenance'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': {
          'stores': stores.map((s) => s.toJson()).toList(),
          'default_store_id': defaultStoreId,
          'app': {
            'currency': currency,
            'currency_symbol': currencySymbol,
            'min_version': minVersion,
            'latest_version': latestVersion,
            'maintenance': maintenance,
          },
          'site': {
            'name': siteName,
            'logo': siteLogo,
            'phone': sitePhone,
            'email': siteEmail,
            'top_bar_text': topBarText,
          },
          'whatsapp': {
            'general': whatsappGeneral,
            'order': whatsappOrder,
          },
        },
      };
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
