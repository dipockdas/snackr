import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';

/// Interface for settings repository
abstract class SettingsRepository {
  /// Get the current app settings
  Future<Either<Failure, AppSettings>> getSettings();

  /// Update app settings
  Future<Either<Failure, AppSettings>> updateSettings(AppSettings settings);

  /// Reset settings to default values
  Future<Either<Failure, AppSettings>> resetToDefaults();

  /// Get the list of available feed categories
  Future<Either<Failure, List<String>>> getCategories();

  /// Add a new category
  Future<Either<Failure, List<String>>> addCategory(String category);

  /// Delete a category
  Future<Either<Failure, List<String>>> deleteCategory(String category);
}