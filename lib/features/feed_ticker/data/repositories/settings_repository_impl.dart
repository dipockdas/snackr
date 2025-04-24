import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> updateSettings(AppSettings settings) async {
    try {
      final settingsModel = AppSettingsModel.fromAppSettings(settings);
      final updatedSettings = await localDataSource.saveSettings(settingsModel);
      return Right(updatedSettings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> resetToDefaults() async {
    try {
      final defaultSettings = await localDataSource.resetToDefaults();
      return Right(defaultSettings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final categories = await localDataSource.getCategories();
      return Right(categories);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> addCategory(String category) async {
    try {
      final categories = await localDataSource.addCategory(category);
      return Right(categories);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> deleteCategory(String category) async {
    try {
      final categories = await localDataSource.deleteCategory(category);
      return Right(categories);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }
}