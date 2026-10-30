import 'package:fmt/models/account_model.dart';
import 'package:fmt/models/user_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:get/get.dart';

/// Account API (auth only): profile, billing/delivery addresses.
/// Password changes ride on `PUT /account/profile` with the three password
/// fields together — omit them to leave the password alone.
class AccountRepository {
  AccountRepository({NetworkService? network})
      : _network = network ?? Get.find();

  final NetworkService _network;

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  /// `GET /account/profile` — name, email, contact, alternate number.
  Future<ApiResponse<UserModel>> profile() async {
    final res = await _network.get(endpoint: ApiPath.accountProfile);
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    final data = _map(res.data!['data']);
    final rawUser = data['user'];
    final userJson =
        rawUser is Map ? _map(rawUser) : {...data, ..._map(res.data)};
    return ApiResponse.completed(UserModel.fromJson(userJson),
        message: res.message);
  }

  /// `PUT /account/profile` — sends the full profile because the backend
  /// validates `name`, `email` and `contact` as required (422 otherwise).
  /// Email is the login identifier: the UI keeps it read-only and resends
  /// the current value. No password keys — omitting the trio leaves the
  /// password alone.
  Future<ApiResponse<UserModel>> updateProfile({
    required String name,
    required String email,
    required String contact,
    String? alternateNumber,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'contact': contact,
    };
    final alt = alternateNumber?.trim();
    if (alt != null && alt.isNotEmpty) body['alternate_number'] = alt;
    final res = await _network.put(
      endpoint: ApiPath.accountProfile,
      body: body,
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '', errors: res.errors);
    }
    final data = _map(res.data!['data']);
    final rawUser = data['user'];
    final userJson = rawUser is Map ? _map(rawUser) : data;
    // Some backends return only a message — fall back to the sent values.
    if (userJson.isEmpty) {
      return ApiResponse.completed(
        UserModel(
          name: name,
          contact: contact,
          alternateNumber: alternateNumber,
        ),
        message: res.message,
      );
    }
    return ApiResponse.completed(UserModel.fromJson(userJson),
        message: res.message);
  }

  /// `PUT /account/profile` with the password trio. The backend validates
  /// the full profile on this endpoint, so the current name/email/contact
  /// travel alongside the trio; the password still only changes when all
  /// three password keys are present.
  Future<ApiResponse<void>> changePassword({
    required String name,
    required String email,
    required String contact,
    String? alternateNumber,
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    // The profile endpoint validates name/email/contact as required, so
    // build the body up-front and only add the optional line when set.
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'contact': contact,
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    final alt = alternateNumber?.trim();
    if (alt != null && alt.isNotEmpty) body['alternate_number'] = alt;
    final res = await _network.put(
      endpoint: ApiPath.accountProfile,
      body: body,
    );
    if (res.isError) {
      return ApiResponse.error(res.message ?? '', errors: res.errors);
    }
    return ApiResponse.completed(null, message: res.message);
  }

  /// `GET /account/addresses` — single record, or null when none yet.
  Future<ApiResponse<CustomerAddress?>> addresses() async {
    final res = await _network.get(endpoint: ApiPath.accountAddresses);
    if (res.isError) return ApiResponse.error(res.message ?? '');
    final data = res.data!['data'];
    final raw = data is Map
        ? (data['address'] ?? data['billing'] ?? data)
        : null;
    if (raw is! Map) return ApiResponse.completed(null, message: res.message);
    return ApiResponse.completed(
      CustomerAddress.fromJson(_map(raw)),
      message: res.message,
    );
  }

  /// `PUT /account/addresses/billing` — overwrites the single record's
  /// billing block. Required: name, address, city, zip, country.
  Future<ApiResponse<CustomerAddress?>> updateBilling({
    required String name,
    required String address,
    required String city,
    required String zip,
    required String country,
    String? phone,
  }) async {
    final res = await _network.put(
      endpoint: ApiPath.accountBillingAddress,
      body: {
        'name': name,
        'address': address,
        'city': city,
        'zip': zip,
        'country': country,
        if (phone != null && phone.trim().isNotEmpty)
          'phone': phone.trim(),
      },
    );
    if (res.isError) {
      return ApiResponse.error(res.message ?? '', errors: res.errors);
    }
    final data = _map(res.data?['data']);
    final raw = data['address'] ?? data['billing'];
    if (raw is! Map) {
      return ApiResponse.completed(
        CustomerAddress(
          name: name,
          address: address,
          city: city,
          zip: zip,
          country: country,
          phone: phone,
        ),
        message: res.message,
      );
    }
    return ApiResponse.completed(
      CustomerAddress.fromJson(_map(raw)),
      message: res.message,
    );
  }

  /// `PUT /account/addresses/delivery` — overwrites the single record's
  /// delivery line. Required: `delivery_address`.
  Future<ApiResponse<void>> updateDelivery({
    required String deliveryAddress,
  }) async {
    final res = await _network.put(
      endpoint: ApiPath.accountDeliveryAddress,
      body: {'delivery_address': deliveryAddress},
    );
    if (res.isError) {
      return ApiResponse.error(res.message ?? '', errors: res.errors);
    }
    return ApiResponse.completed(null, message: res.message);
  }
}
