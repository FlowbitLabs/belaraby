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
    return Container(
      color: const Color.fromARGB(255, 241, 241, 241),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'home_title'.tr(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Padding(
            padding: const EdgeInsetsGeometry.only(left: 23, top: 5),
            child: Icon(Icons.account_box, size: 40, color: Colors.yellow[800]),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(HomeHeaderDelegate oldDelegate) => false;
}
