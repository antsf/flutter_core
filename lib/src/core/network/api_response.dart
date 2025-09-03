import 'package:flutter/widgets.dart';
import 'package:flutter_core/flutter_core.dart' show Response;

/// Generic envelope for every API response
class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;

  const ApiResponse({required this.status, required this.message, this.data});

  /// `fromJson` needs a function that turns a json-map into the concrete data object
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataBuilder,
  ) {
    debugPrint('json: $json');
    return ApiResponse<T>(
      status: json['status'] as String,
      message: json['message'] as String,
      data: json['data'] != null ? dataBuilder(json['data']) : null,
    );
  }
}

extension ResponseX on Response<dynamic> {
  bool get hasError => (statusCode ?? 0) > 300;
}
