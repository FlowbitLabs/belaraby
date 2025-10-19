part of 'my_library_page.dart';

class MyLibraryView extends StatelessWidget {
  const MyLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F1F1),
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: _HeaderDelegate(),
            ),
          ),
          SliverToBoxAdapter(child: MyLibraryButtons()),
        ],
      ),
    );
  }
}

class MyLibraryButtons extends StatelessWidget {
  const MyLibraryButtons({super.key});
  String calculateItems(BuildContext context, {required int items}) {
    if (items < 1) return 'لا توجد عناصر';
    if (items == 1) return 'عنصر واحد';
    if (items == 2) return 'عنصران';

    final arabicDigits = convertToArabicDigits(number: items);
    if (items >= 3 && items <= 10) return '$arabicDigits عناصر';
    if (items >= 11 && items < 100) return '$arabicDigits عنصراً';
    return '$arabicDigits عنصر';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _buildLibraryButton(
            context,
            label: L10n.of(context).library_favorites,
            itemCount: calculateItems(context, items: 0),
            trailingIcon: Icons.favorite_border,
            onPressed: () {
              // TODO(test): Navigate to Favorites
            },
          ),
          const SizedBox(height: 12),
          _buildLibraryButton(
            context,
            label: L10n.of(context).library_learned_stories,
            itemCount: calculateItems(context, items: 0),
            trailingIcon: Icons.library_add_check,
            onPressed: () {
              // TODO(test): Navigate to Learned Stories
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryButton(
    BuildContext context, {
    required String label,
    required IconData trailingIcon,
    required VoidCallback onPressed,
    required String itemCount,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right icon
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 5),
              child: Icon(trailingIcon, size: 40, color: Colors.yellow[800]),
            ),
            // Label with subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Text(
                    itemCount,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Left arrow icon
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate();

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
            L10n.of(context).navbar_my_library,
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
