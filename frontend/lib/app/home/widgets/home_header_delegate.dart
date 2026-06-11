import 'package:belaraby/app/router.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  const HomeHeaderDelegate();

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // `alignment` makes the Container expand to fill the sliver's extent —
    // a pinned persistent header must be exactly minExtent/maxExtent tall,
    // or the sliver reports invalid geometry and rendering throws.
    return Container(
      color: appBackground,
      padding: const EdgeInsetsDirectional.only(start: 24, end: 12),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'home_title'.tr(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 4),
            child: IconButton(
              icon: const Icon(
                Icons.account_box,
                size: 40,
                color: yellow120,
              ),
              tooltip: 'settings_title'.tr(),
              onPressed: () => navigateToSettings(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(HomeHeaderDelegate oldDelegate) => false;
}
