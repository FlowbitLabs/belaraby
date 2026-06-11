import 'package:belaraby/app/settings/cubit/auth_cubit.dart';
import 'package:belaraby/app/settings/cubit/settings_cubit.dart';
import 'package:belaraby/app/settings/view/about_page.dart';
import 'package:belaraby/app/settings/widgets/account_header.dart';
import 'package:belaraby/app/settings/widgets/account_tiles.dart';
import 'package:belaraby/app/settings/widgets/learning_progress_card.dart';
import 'package:belaraby/app/settings/widgets/manage_subscription_tile.dart';
import 'package:belaraby/app/settings/widgets/restore_purchases_tile.dart';
import 'package:belaraby/app/settings/widgets/settings_section.dart';
import 'package:belaraby/app/settings/widgets/settings_tile.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_view.dart';

/// The profile page: account header (tier + subscribe CTA), gamified
/// learning progress, account management (sign-in/up, sign-out, deletion),
/// subscription tools and the about sub-page.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit()..loadAppVersion()),
        BlocProvider(create: (_) => AuthCubit()..load()),
      ],
      child: const SettingsView(),
    );
  }
}
