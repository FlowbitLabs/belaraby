import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// WEB ONLY — toggles a locally simulated premium account so the premium
/// UI can be demonstrated without going through the store purchase flow.
class DemoPremiumToggle extends StatelessWidget {
  const DemoPremiumToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDemo = context.select(
      (SubscriptionCubit cubit) => cubit.state.isDemoPremium,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () =>
              context.read<SubscriptionCubit>().toggleDemoPremium(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            isDemo ? Icons.science : Icons.science_outlined,
            size: 18,
          ),
          label: Text(
            isDemo ? 'profile_demo_disable'.tr() : 'profile_demo_enable'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'profile_demo_description'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
