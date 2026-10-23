import 'package:fmt/network/response/status.dart';

class ApiResponse<T> {
  final Status? status;
  final T? data;
  final String? message;
  final Map<String, List<String>>? errors;

  ApiResponse({
    this.status,
    this.data,
    this.message,
    this.errors,
  });

  /// Loading
  factory ApiResponse.loading() => ApiResponse(status: Status.loading);

  /// Success
  factory ApiResponse.completed(T data, {String? message}) =>
      ApiResponse(
        status: Status.completed,
        data: data,
        message: message,
      );

  /// Error (with optional validation errors)
  factory ApiResponse.error(
    String message, {
    T? data,
    Map<String, List<String>>? errors,
  }) =>
      ApiResponse(
        status: Status.error,
        message: message,
        data: data,
        errors: errors,
      );

  /// Helpers (VERY USEFUL)
  bool get isLoading => status == Status.loading;
  bool get isCompleted => status == Status.completed;
  bool get isError => status == Status.error;

  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  /// Combine all validation errors into one string
  String get validationErrorsSummary {
    if (errors == null) return '';
    return errors!.values.expand((e) => e).join('\n');
  }
  
  @override
  String toString() {
    return 'Status: $status\nMessage: $message\nData: $data\nErrors: $errors';
  }
}