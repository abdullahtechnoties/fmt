import 'package:fmt/models/user_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:fmt/utilities/app_strings.dart';
import 'package:get/get.dart';

/// Result of a successful register/login call.
class AuthResult {
  AuthResult({required this.token, required this.user});

  final String token;
  final UserModel user;
}

/// Auth API: register, login (email or WhatsApp), forgot-password, me, logout.
///
/// Sends the stored `X-Cart-Token` on register/login so a guest cart merges
/// into the account automatically (per API docs).
class AuthRepository {
  AuthRepository({NetworkService? network}) : _network = network ?? Get.find();

  final NetworkService _network;

  Map<String, String>? _cartTokenHeader() {
    final token = LocalStorageService.prefs?.getString(AppStrings.cartToken);
    if (token == null || token.isEmpty) return null;
    return {'X-Cart-Token': token};
  }

  Future<ApiResponse<AuthResult>> register({
    required String name,
    required String email,
    required String whatsapp,
    required String alternateNumber,
    required String city,
    required String district,
    required String password,
    required String passwordConfirmation,
    String? deviceName,
  }) async {
    final res = await _network.post(
      endpoint: ApiPath.register,
      extraHeaders: _cartTokenHeader(),
      body: {
        'name': name,
        'email': email,
        'whatsapp': whatsapp,
        'alternate_number': alternateNumber,
        'city': city,
        'district': district,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (deviceName != null && deviceName.isNotEmpty)
          'device_name': deviceName,
      },
    );
    return _toAuthResult(res);
  }

  Future<ApiResponse<AuthResult>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _network.post(
      endpoint: ApiPath.login,
      extraHeaders: _cartTokenHeader(),
      body: {'email': email, 'password': password},
    );
    return _toAuthResult(res);
  }

  Future<ApiResponse<AuthResult>> loginWithWhatsapp({
    required String whatsapp,
    required String password,
  }) async {
    final res = await _network.post(
      endpoint: ApiPath.login,
      extraHeaders: _cartTokenHeader(),
      body: {
        'login_type': 'whatsapp',
        'whatsapp': whatsapp,
        'password': password,
      },
    );
    return _toAuthResult(res);
  }

  Future<ApiResponse<void>> forgotPassword({required String email}) async {
    final res = await _network.post(
      endpoint: ApiPath.forgotPassword,
      body: {'email': email},
    );
    if (res.isError) return ApiResponse.error(res.message ?? '');
    return ApiResponse.completed(null, message: res.message);
  }

  Future<ApiResponse<UserModel>> me() async {
    final res = await _network.get(endpoint: ApiPath.me);
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    final data = res.data!;
    final rawUser = data['data'] is Map ? data['data']['user'] : null;
    final userJson =
        rawUser is Map ? Map<String, dynamic>.from(rawUser) : _userFrom(data);
    return ApiResponse.completed(UserModel.fromJson(userJson),
        message: res.message);
  }

  Future<ApiResponse<void>> logout() async {
    final res = await _network.post(endpoint: ApiPath.logout);
    if (res.isError) return ApiResponse.error(res.message ?? '');
    return ApiResponse.completed(null, message: res.message);
  }

  Future<ApiResponse<AuthResult>> _toAuthResult(
    ApiResponse<Map<String, dynamic>> res,
  ) async {
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '', errors: res.errors);
    }
    final data = res.data!;
    final payload = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    final token = payload['token']?.toString() ?? '';
    final rawUser = payload['user'];
    if (token.isEmpty || rawUser is! Map) {
      return ApiResponse.error(res.message ?? '');
    }
    final user =
        UserModel.fromJson(Map<String, dynamic>.from(rawUser));
    return ApiResponse.completed(AuthResult(token: token, user: user),
        message: res.message);
  }

  Map<String, dynamic> _userFrom(Map<String, dynamic> data) {
    final payload = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    return payload;
  }

  /// Persist session: Bearer token + user + authenticated flag.
  Future<void> persistSession(AuthResult result) async {
    final auth = Get.find<AuthService>();
    await auth.setAccessToken(result.token);
    await auth.setCurrentUser(result.user);
    await AuthService.setAuthenticated(true);
  }
}
