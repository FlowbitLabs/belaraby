import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Underlined text button that restores previous purchases; disabled while
/// billing is unavailable or a subscription operation is in flight.
class RestorePurchasesButton extends StatelessWidget {
  const RestorePurchasesButton({super.key});

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
        return TextButton(
          onPressed: isEnabled
              ? () => context.read<SubscriptionCubit>().restore()
              : null,
          child: Text(
            'paywall_restore'.tr(),
            style: const TextStyle(
              color: grey160,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}
