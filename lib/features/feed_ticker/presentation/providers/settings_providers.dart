import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/local_database.dart';
import '../../data/datasources/settings_local_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_app_settings.dart';
import '../../domain/usecases/update_app_settings.dart';
import 'feed_providers.dart' as feed_providers;
import '../../../../core/usecases/usecase.dart';

part 'settings_providers.g.dart';

// Infrastructure providers
final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSourceImpl(database: ref.watch(feed_providers.databaseProvider));
});

// Importing the database provider from feed_providers.dart
// Use the database provider from feed_providers.dart to avoid duplication
// This is just for reference - we're using feed_providers.databaseProvider below
// final databaseProvider = Provider<LocalDatabase>((ref) {
//   return LocalDatabase();
// });

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    localDataSource: ref.watch(settingsLocalDataSourceProvider),
  );
});

// Use case providers
final getAppSettingsUseCaseProvider = Provider<GetAppSettings>((ref) {
  return GetAppSettings(ref.watch(settingsRepositoryProvider));
});

final updateAppSettingsUseCaseProvider = Provider<UpdateAppSettings>((ref) {
  return UpdateAppSettings(ref.watch(settingsRepositoryProvider));
});

// State providers
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final useCase = ref.watch(getAppSettingsUseCaseProvider);
    final result = await useCase(NoParams());
    
    return result.fold(
      (failure) => const AppSettings(), // Return default settings on failure
      (settings) => settings,
    );
  }
  
  Future<void> updateSettings(AppSettings settings) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(updateAppSettingsUseCaseProvider);
    final result = await useCase(UpdateAppSettingsParams(settings: settings));
    
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (updatedSettings) => AsyncValue.data(updatedSettings),
    );
  }
  
  Future<void> resetToDefaults() async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.resetToDefaults();
    
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (defaultSettings) => AsyncValue.data(defaultSettings),
    );
  }
}