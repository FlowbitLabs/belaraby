import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/settings/cubit/settings_cubit.dart';
import 'package:belaraby/app/settings/widgets/delete_account_dialog.dart';
import 'package:belaraby/app/settings/widgets/settings_section.dart';
import 'package:belaraby/app/settings/widgets/settings_tile.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/app/util/launch_external_url.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/legal_links.dart';
import 'package:belaraby/constant/store_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_view.dart';

/// App settings: language, subscription management, legal links and
/// account deletion (Apple 5.1.1(v) / Google Play account-deletion policy).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit()..loadAppVersion(),
      child: const SettingsView(),
    );
  }
}
