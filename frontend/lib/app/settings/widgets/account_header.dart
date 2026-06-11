import 'package:belaraby/app/router.dart';
import 'package:belaraby/app/settings/cubit/auth_cubit.dart';
import 'package:belaraby/app/settings/widgets/demo_premium_toggle.dart';
import 'package:belaraby/app/settings/widgets/tier_badge.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Profile header: identity (email or guest), account tier badge and a
/// subscribe call-to-action for free users.
class AccountHeader extends StatelessWidget {
  const AccountHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isPremium = context.select(
      (SubscriptionCubit cubit) => cubit.state.isPremium,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        color: navy140,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: navy110,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.isAnonymous
                              ? 'profile_guest'.tr()
                              : (authState.username.isNotEmpty
                                    ? authState.username
                                    : authState.email),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TierBadge(isPremium: isPremium),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isPremium) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => navigateToPaywall(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow120,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.workspace_premium, size: 20),
                    label: Text(
                      'profile_subscribe_now'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              // Web demo toggle — only for signed-in accounts on the
              // server's demo allowlist (never for anonymous guests). Also
              // kept visible while a demo subscription is active, so it can
              // always be cancelled even if the allowlist check hiccups.
              if (context.select(
                (SubscriptionCubit cubit) =>
                    cubit.state.isDemoAuthorized || cubit.state.isDemoPremium,
              )) ...[
                const SizedBox(height: 12),
                const DemoPremiumToggle(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
