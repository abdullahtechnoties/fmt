import 'dart:developer';
import 'dart:io';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/png_assets.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;


class NetworkService extends GetxService {
  // ─── Private state ─────────────────────────────────────────────────────────
  late final Dio _dio;
  late final AuthService _auth;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthService>();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiPath.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        // validateStatus accepts everything < 600 so Dio never throws on
        // 4xx / 5xx — we handle every status code ourselves.
        validateStatus: (status) => status != null && status < 600,
        headers: {HttpHeaders.acceptHeader: 'application/json'},
      ),
    );
    _addInterceptors();
    _log('NetworkService initialised', icon: '🚀');
  }

  // ─── Interceptors ──────────────────────────────────────────────────────────

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _auth.accessToken.value;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    _log(options.headers.toString());
    _log('${options.method}  ${options.uri}', icon: '📤');
    if (options.data != null) _log('Body → ${options.data}', icon: '📦');
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('${response.statusCode}  ${response.requestOptions.uri}', icon: '📥');
    handler.next(response);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) {
    _log('DioError [${error.type}]  ${error.message}', icon: '❌');
    handler.next(error);
  }

  // ─── Public HTTP Methods ────────────────────────────────────────────────────

  /// HTTP GET — query params are appended to the URL automatically.
  Future<ApiResponse<Map<String, dynamic>>> get({
    required String endpoint,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return _processResponse(response);
    } on DioException catch (e) {
      return _processDioException(e);
    } catch (e) {
      return _processUnknownException(e);
    }
  }

  /// HTTP POST with a JSON body.
  ///
  /// Pass [contentType] (e.g. [Headers.formUrlEncodedContentType]) when the
  /// endpoint expects something other than JSON.
  Future<ApiResponse<Map<String, dynamic>>> post({
    required String endpoint,
    Map<String, dynamic>? body,
    String? contentType,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: contentType != null
            ? Options(contentType: contentType)
            : null,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _processDioException(e);
    } catch (e) {
      return _processUnknownException(e);
    }
  }

  /// HTTP POST with multipart/form-data — use this for file uploads.
  ///
  /// [fields]  — plain text fields  (e.g. name, email, role …)
  /// [files]   — file fields        (e.g. profile_image, nic_f, nic_b …)
  /// [onSendProgress] — optional upload progress callback (bytes sent / total)
  ///
  /// Example:
  /// ```dart
  /// await _network.postForm(
  ///   endpoint: ApiPath.register,
  ///   fields: {
  ///     'name': 'Rafay', 'email': 'rafay@example.com',
  ///     'role': 'Vendor', 'city': 'Karachi',
  ///   },
  ///   files: {
  ///     'profile_image': File(pickedImagePath),
  ///     'nic_f': File(nicFrontPath),
  ///     'nic_b': File(nicBackPath),
  ///   },
  ///   onSendProgress: (sent, total) {
  ///     final percent = (sent / total * 100).toStringAsFixed(0);
  ///     print('Upload: $percent%');
  ///   },
  /// );
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> postForm({
    required String endpoint,
    Map<String, dynamic>? fields,
    Map<String, File>? files,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = await _buildFormData(fields: fields, files: files);
      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
      );
      _log('Response → ${response.data.toString()}', icon: '📥');
      return _processResponse(response);
    } on DioException catch (e) {
      return _processDioException(e);
    } catch (e) {
      return _processUnknownException(e);
    }
  }

  /// HTTP PUT with a JSON body.
  Future<ApiResponse<Map<String, dynamic>>> put({
    required String endpoint,
    Map<String, dynamic>? body,
    // content type 
    String? contentType,
  }) async {
    try {
      final response = await _dio.put(
        endpoint, data: body
        , options: contentType != null
            ? Options(contentType: contentType)
            : null,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _processDioException(e);
    } catch (e) {
      return _processUnknownException(e);
    }
  }

  /// HTTP PUT with multipart/form-data — use this for profile updates with files.
  Future<ApiResponse<Map<String, dynamic>>> putForm({
    required String endpoint,
    Map<String, dynamic>? fields,
    Map<String, File>? files,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = await _buildFormData(fields: fields, files: files);
      final response = await _dio.put(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _processDioException(e);
    } catch (e) {
      return _processUnknownException(e);
    }
  }

  /// HTTP PATCH with a JSON body.
  Future<ApiResponse<Map<String, dynamic>>> patch({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.patch(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      return _processDioException(e);
    } catch (e) {
      return _processUnknownException(e);
    }
  }

  /// HTTP DELETE — optionally pass a JSON body (some APIs require it).
  Future<ApiResponse<Map<String, dynamic>>> delete({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.delete(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      return _processDioException(e);
    } catch (e) {
      return _processUnknownException(e);
    }
  }

  // ─── Response Processing ────────────────────────────────────────────────────

  /// Central response handler — every HTTP response flows through here.
  ApiResponse<Map<String, dynamic>> _processResponse(Response response) {
    final int? statusCode = response.statusCode;
    final dynamic raw = response.data;

    _log('Processing [$statusCode]', icon: '🔍');

    // Guard: body must be a Map
    if (raw == null) {
      final msg = 'errors.emptyResponse'.trns();
      _log(msg, icon: '⚠️');
      _showError(msg);
      return ApiResponse.error(msg);
    }

    // Some endpoints (e.g. brand lookup) return a bare JSON array at the top
    // level. Wrap it under a "data" key so callers can read data['data']
    // uniformly regardless of the response shape.
    final body = raw is Map<String, dynamic>
        ? raw
        : (raw is List ? <String, dynamic>{'data': raw} : <String, dynamic>{});
    final String message = (() {
      final m = body['message'];
      if (m == null) return '';
      if (m is String) return m;
      if (m is Map || m is List) return '';
      return m.toString();
    })();

    // ── 2xx ──────────────────────────────────────────────────────────────────
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      // Server may return {"status": false} even on HTTP 200 (soft failure).
      // Some endpoints use `success` instead of `status`.
      // A top-level list is a valid success body (no status/success key).
      // final bool bodyStatus = body['status'] == true ||
      //     body['success'] == true ||
      //     body.containsKey('data');

      // if (bodyStatus) {
        _log('Success: $message', icon: '✅');
        return ApiResponse.completed(body, message: message);
      // } else {
      //   _log('Soft failure: $message', icon: '⚠️');
      //   _showError(message);
      //   return ApiResponse.error(message);
      // }
    }

    // ── 400 Validation errors ─────────────────────────────────────────────────
    if (statusCode == 400 || statusCode == 422) {
      final errors = _extractValidationErrors(body);
      final display = message.isNotEmpty ? message : 'errors.validationFailed'.trns();
      _log('Validation errors: $errors', icon: '🛑');
      _showError(display);
      return ApiResponse.error(display, errors: errors);
    }

    // ── 401 Unauthorised → dialog + redirect ──────────────────────────────────
    if (statusCode == 401) {
      _log('Unauthorised — redirecting to login', icon: '🔒');
      _showUnauthorisedDialog();
      return ApiResponse.error(
        message.isNotEmpty ? message : 'errors.unauthorized'.trns(),
      );
    }

    // ── 403 / 404 / 422 ───────────────────────────────────────────────────────
    if (statusCode == 403 || statusCode == 404 || statusCode == 422) {
      final errors = _extractValidationErrors(body);
      final display = message.isNotEmpty ? message : 'errors.requestFailed'.trns();
      _log('[$statusCode] $display', icon: '⚠️');
      _showError(display);
      return ApiResponse.error(display, errors: errors);
    }

    // ── 500 Server error ──────────────────────────────────────────────────────
    if (statusCode == 500) {
      final display = message.isNotEmpty
          ? message
          : 'errors.internalServerError'.trns();
      _log('Server error: $display', icon: '🔥');
      _showError(display);
      return ApiResponse.error(display);
    }

    // ── Fallback ──────────────────────────────────────────────────────────────
    final fallback = 'errors.unexpectedResponse'.trns();
    _log('Unexpected response (HTTP $statusCode).', icon: '❓');
    _showError(fallback);
    return ApiResponse.error(fallback);
  }

  // ─── Exception Handlers ─────────────────────────────────────────────────────

  ApiResponse<Map<String, dynamic>> _processDioException(DioException e) {
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'errors.connectionTimeout'.trns();
        _log(message, icon: '⏳');
        break;

      case DioExceptionType.connectionError:
        message = 'errors.noInternet'.trns();
        _log(message, icon: '🚫');
        break;

      case DioExceptionType.badResponse:
        // Should not reach here (validateStatus catches all), but just in case.
        if (e.response != null) return _processResponse(e.response!);
        message = 'errors.badResponse'.trns();
        _log(message, icon: '❌');
        break;

      case DioExceptionType.cancel:
        message = 'errors.requestCancelled'.trns();
        _log(message, icon: '🚫');
        break;

      default:
        message = e.message ?? 'errors.unexpectedShort'.trns();
        _log('DioException: $message', icon: '❌');
    }

    _showError(message);
    return ApiResponse.error(message);
  }

  ApiResponse<Map<String, dynamic>> _processUnknownException(Object e) {
    final message = 'errors.unexpected'.trns();
    _log('Unknown exception: $e', icon: '💥');
    _showError(message);
    return ApiResponse.error(message);
  }

  // ─── Private Helpers ────────────────────────────────────────────────────────

  /// Builds a [FormData] object from text [fields] and [File] objects.
  Future<FormData> _buildFormData({
    Map<String, dynamic>? fields,
    Map<String, File>? files,
  }) async {
    final Map<String, dynamic> map = {};

    // Add plain text fields (null values are skipped)
    if (fields != null) {
      fields.forEach((key, value) {
        if (value == null) return;
        // Preserve lists/maps for endpoints that expect arrays (e.g. working_days[])
        if (value is List || value is Map) {
          map[key] = value;
        } else {
          map[key] = value.toString();
        }
      });
    }

    // Add files as MultipartFile
    if (files != null) {
      for (final entry in files.entries) {
        final filename = entry.value.path.split('/').last;
        map[entry.key] = await MultipartFile.fromFile(
          entry.value.path,
          filename: filename,
        );
      }
    }

    _log('FormData keys: ${map.keys.join(', ')}', icon: '📎');
    return FormData.fromMap(map);
  }

  /// Extracts `{"errors": {"field": ["message"]}}` from the response body.
  Map<String, List<String>>? _extractValidationErrors(
    Map<String, dynamic> body,
  ) {
    final raw = body['errors'];
    if (raw == null || raw is! Map) return null;

    final result = <String, List<String>>{};
    (raw as Map<String, dynamic>).forEach((key, value) {
      if (value is List) {
        result[key] = value.map((e) => e.toString()).toList();
      }
    });
    return result.isEmpty ? null : result;
  }

  /// Shows a non-dismissible dialog and navigates to login when OK is tapped.
  void _showUnauthorisedDialog() {
    if (Get.isDialogOpen == true) return; // prevent stacking dialogs

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 324,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(52),
                      color: AppColors.red.withValues(alpha: 0.10),
                    ),
                    child: Image.asset(
                      PngAssets.commonAlertIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'errors.sessionExpired.title'.trns(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'errors.sessionExpired.message'.trns(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(
                    () => GestureDetector(
                      onTap: () async {
                        await AuthService.forceLogout(showLogin: false);
                        Get.offAllNamed(Routes.LOGIN);
                      },
                      child: AuthService.isLogoutInProgress
                          ? SizedBox(
                              width: 30,
                              height: 30,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Container(
                              width: 88,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: AppColors.secondary,
                              ),
                              child: Center(
                                child: Text(
                                  'auth.login.login_btn'.trns(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showError(String message) {
    if (message.isEmpty) return;
    SnackbarService.showError(title: 'errors.errorTitle'.trns(), message: message);
  }

  void _log(String message, {String icon = '📄'}) {
    // if (kDebugMode) debugPrint('[$NetworkService] $icon  $message');
    log('[$NetworkService] $icon  $message', name: 'NetworkService');
  }
}
