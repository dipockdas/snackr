import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateAppSettings implements UseCase<AppSettings, UpdateAppSettingsParams> {
  final SettingsRepository repository;

  UpdateAppSettings(this.repository);

  @override
  Future<Either<Failure, AppSettings>> call(UpdateAppSettingsParams params) async {
    return await repository.updateSettings(params.settings);
  }
}

class UpdateAppSettingsParams extends Equatable {
  final AppSettings settings;

  const UpdateAppSettingsParams({required this.settings});

  @override
  List<Object> get props => [settings];
}