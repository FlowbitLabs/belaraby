import 'package:belaraby/app/settings/widgets/settings_tile.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tile that triggers the restore-purchases flow when billing is available.
class RestorePurchasesTile extends StatelessWidget {
  const RestorePurchasesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isBillingAvailable != current.isBillingAvailable,
      builder: (context, state) {
        final isEnabled =
            state.isBillingAvailable &&
            state.status != SubscriptionStatus.loading;
        return SettingsTile(
          icon: Icons.restore,
          label: 'paywall_restore'.tr(),
          trailing: state.status == SubscriptionStatus.loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: yellow120,
                  ),
                )
              : null,
          onTap: isEnabled
              ? () => context.read<SubscriptionCubit>().restore()
              : null,
        );
      },
    );
  }
}
