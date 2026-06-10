import 'package:belaraby/data/repositories/auth_repository.dart';
import 'package:belaraby/data/services/app_info_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SettingsStatus { initial, loading, success, error }

/// Cubit for the settings screen: app version and account deletion.
///
/// Subscription concerns (restore, premium status) stay in the global
/// `SubscriptionCubit`; the language switch goes through easy_localization
/// directly from the view.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({AuthRepository? authRepository, AppInfoService? appInfo})
    : _authRepository = authRepository ?? AuthRepository(),
      _appInfo = appInfo ?? AppInfoService(),
      super(const SettingsState());

  final AuthRepository _authRepository;
  final AppInfoService _appInfo;

  /// Loads the app version label shown in the about section.
  Future<void> loadAppVersion() async {
    final version = await _appInfo.getVersionLabel();
    if (isClosed) return;
    emit(state.copyWith(appVersion: version));
  }

  /// Permanently deletes the account, then starts a fresh anonymous session.
  Future<void> deleteAccount() async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: ''));
    try {
      await _authRepository.deleteAccount();
      emit(
        state.copyWith(status: SettingsStatus.success, accountDeleted: true),
      );
    } on Exception catch (error) {
      debugPrint('SettingsCubit.deleteAccount failed: $error');
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: 'settings_delete_error',
        ),
      );
    }
  }
}

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.appVersion = '',
    this.accountDeleted = false,
    this.errorMessage = '',
  });

  final SettingsStatus status;
  final String appVersion;

  /// Whether the account was deleted; the view pops back to home on `true`.
  final bool accountDeleted;

  /// Translation key for the snackbar shown on failures.
  final String errorMessage;

  @override
  List<Object?> get props => [status, appVersion, accountDeleted, errorMessage];

  SettingsState copyWith({
    SettingsStatus? status,
    String? appVersion,
    bool? accountDeleted,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      appVersion: appVersion ?? this.appVersion,
      accountDeleted: accountDeleted ?? this.accountDeleted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
