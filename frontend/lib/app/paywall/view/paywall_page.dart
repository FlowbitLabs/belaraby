import 'package:belaraby/app/paywall/widgets/paywall_feature_row.dart';
import 'package:belaraby/app/paywall/widgets/paywall_package_card.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/app/util/launch_external_url.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/legal_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'paywall_view.dart';

/// Premium subscription paywall.
///
/// Reuses the global [SubscriptionCubit]; pops with `true` after a
/// successful purchase or restore so callers can continue to the locked
/// content.
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaywallView();
  }
}
