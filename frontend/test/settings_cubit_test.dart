import 'package:belaraby/app/settings/cubit/settings_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockAuthRepository auth;
  late MockAppInfoService appInfo;

  setUp(() {
    auth = MockAuthRepository();
    appInfo = MockAppInfoService();
  });

  SettingsCubit buildCubit() =>
      SettingsCubit(authRepository: auth, appInfo: appInfo);

  group('loadAppVersion', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits the version label',
      setUp: () {
        when(
          () => appInfo.getVersionLabel(),
        ).thenAnswer((_) async => '1.0.0 (1)');
      },
      build: buildCubit,
      act: (cubit) => cubit.loadAppVersion(),
      expect: () => [const SettingsState(appVersion: '1.0.0 (1)')],
    );
  });

  group('deleteAccount', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits accountDeleted on success',
      setUp: () {
        when(() => auth.deleteAccount()).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.deleteAccount(),
      expect: () => [
        const SettingsState(status: SettingsStatus.loading),
        const SettingsState(
          status: SettingsStatus.success,
          accountDeleted: true,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits error and stays on the screen when the deletion fails',
      setUp: () {
        when(() => auth.deleteAccount()).thenThrow(Exception('boom'));
      },
      build: buildCubit,
      act: (cubit) => cubit.deleteAccount(),
      expect: () => [
        const SettingsState(status: SettingsStatus.loading),
        const SettingsState(
          status: SettingsStatus.error,
          errorMessage: 'settings_delete_error',
        ),
      ],
    );
  });
}
