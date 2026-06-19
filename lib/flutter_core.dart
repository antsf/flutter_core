library flutter_core;

// Core initialization
export 'core.dart';

// Theme
export 'src/theme/theme.dart';
export 'src/theme/theme_provider.dart';
export 'src/theme/text_theme.dart';
export 'src/theme/color_schemes.dart';

// Failures & Result
export 'src/domain/failures.dart';

// Network exceptions & utilities
export 'src/network/exceptions/network_exceptions.dart';
export 'src/network/dio_client.dart';
export 'src/network/dio_retry_interceptor.dart';
export 'src/network/api_response.dart';
export 'src/domain/safe_call.dart';

// Services
export 'src/services/connectivity_service.dart';

// Storage
export 'src/storage/local_storage.dart';

// Constants
export 'src/constants/constants.dart';

// Utils
export 'src/utils/utils.dart';

// Domain
export 'src/domain/usecase.dart';

// Extensions
export 'src/extensions/extensions.dart';

// External packages re-exported for consumer convenience
export 'package:dio/dio.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:intl/intl.dart';
export 'package:connectivity_plus/connectivity_plus.dart';
