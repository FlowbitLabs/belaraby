import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LibraryHeaderDelegate extends SliverPersistentHeaderDelegate {
  const LibraryHeaderDelegate();

  static const double _headerHeight = 60;
  static const Color _backgroundColor = Color(0xFFF1F1F1);

  @override
  double get minExtent => _headerHeight;

  @override
  double get maxExtent => _headerHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Text(
            'navbar_my_library'.tr(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
