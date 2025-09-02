/// Main export file for the Flutter Core package.

library flutter_core;

/// Barrel file for exporting all core data sources, models, and repositories.

// Core initialization
export 'core.dart';

// Theme
export 'src/theme/theme.dart';
export 'src/theme/theme_provider.dart';
export 'src/theme/text_theme.dart';
export 'src/theme/color_schemes.dart';

// Core exceptions and failures
export 'src/core/domain/failures/failures.dart';
export 'src/core/network/exceptions/network_exceptions.dart';

// Network
// export 'src/core/network/dio_client.dart';
// export 'src/core/network/dio_interceptor.dart';
// export 'src/core/network/dio_cache_config.dart';
// export 'src/core/network/dio_retry_interceptor.dart';

// Services
export 'src/core/services/connectivity_service.dart';
export 'src/core/services/storage_service.dart';

// Storage
export 'src/core/storage/key_manager.dart';
export 'src/core/storage/secure_storage_service.dart';

// Constants
export 'src/constants/constants.dart';

// Utils
export 'src/utils/utils.dart';

// Domain
export 'src/core/domain/entities/base_entity.dart';
export 'src/core/domain/repositories/base_repository.dart';
export 'src/core/domain/usecases/base_usecase.dart';

// Data
export 'src/core/data/datasources/base_local_data_source.dart';
export 'src/core/data/datasources/base_remote_data_source.dart';
export 'src/core/data/models/base_model.dart';
export 'src/core/data/repositories/base_repository_impl.dart';

// Extensions
export 'src/extensions/extensions.dart';

// external package
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:rxdart/rxdart.dart';
export 'package:intl/intl.dart';
