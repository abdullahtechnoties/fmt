/// Account address payloads.
///
/// The website stores a single address record per customer and the app
/// matches it: `GET /account/addresses` returns the record (or null),
/// `PUT /account/addresses/billing` overwrites the billing block and
/// `PUT /account/addresses/delivery` overwrites the delivery line.
class CustomerAddress {
  CustomerAddress({
    this.name,
    this.address,
    this.city,
    this.zip,
    this.country,
    this.phone,
    this.deliveryAddress,
  });

  final String? name;
  final String? address;
  final String? city;
  final String? zip;
  final String? country;
  final String? phone;
  final String? deliveryAddress;

  bool get hasBilling =>
      (address ?? '').trim().isNotEmpty ||
      (city ?? '').trim().isNotEmpty;

  bool get hasDelivery => (deliveryAddress ?? '').trim().isNotEmpty;

  /// Short one-liner for tiles ("House 12, Street 3, Lahore").
  String get summaryLine {
    final parts = [
      address?.trim(),
      city?.trim(),
      country?.trim(),
    ].where((p) => p != null && p.isNotEmpty).cast<String>().toList();
    if (parts.isEmpty) return '';
    return parts.join(', ');
  }

  static String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v != null && '$v'.trim().isNotEmpty) return '$v'.trim();
    }
    return null;
  }

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    final nested = json['billing'] is Map
        ? Map<String, dynamic>.from(json['billing'])
        : json;
    return CustomerAddress(
      name: _str(nested, ['name', 'billing_name', 'full_name']),
      address: _str(nested, ['address', 'billing_address', 'street']),
      city: _str(nested, ['city', 'billing_city']),
      zip: _str(nested, ['zip', 'billing_zip', 'postal_code']),
      country: _str(nested, ['country', 'billing_country']),
      phone: _str(nested, ['phone', 'billing_phone', 'contact']),
      deliveryAddress: _str(json, ['delivery_address', 'shipping_address']),
    );
  }
}
