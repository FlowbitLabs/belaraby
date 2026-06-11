import 'dart:async';

import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/router.dart';
import 'package:belaraby/app/settings/cubit/auth_cubit.dart';
import 'package:belaraby/app/settings/cubit/settings_cubit.dart';
import 'package:belaraby/app/settings/view/about_page.dart';
import 'package:belaraby/app/settings/view/auth_page.dart';
import 'package:belaraby/app/settings/widgets/delete_account_dialog.dart';
import 'package:belaraby/app/settings/widgets/learning_progress_card.dart';
import 'package:belaraby/app/settings/widgets/settings_section.dart';
import 'package:belaraby/app/settings/widgets/settings_tile.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/app/util/launch_external_url.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/store_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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
