part of 'home_page.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.error) {
              return Center(
                child: Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (state.freeLessons.isEmpty) {
              return const Center(child: Text('No lessons available'));
            }

            return CustomScrollView(
              slivers: [
                SliverSafeArea(
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: _HeaderDelegate(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FreeLessons(lessons: state.freeLessons),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'home_filter'.tr(args: [state.filterBy]),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),

                            TextButton(
                              onPressed: () {
                                context.read<HomeCubit>().filterBy('الكل');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'home_hide_learnt'.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.check_circle_outline_outlined,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _LessonsSelectorDelegate(),
                ),
                SliverToBoxAdapter(
                  child: LessonsSection(
                    lessons: state.paidLessonsBySelectedLevel,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
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
  bool shouldRebuild(_HeaderDelegate oldDelegate) => false;
}

class _LessonsSelectorDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Container(
          color: const Color.fromARGB(255, 241, 241, 241),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          alignment: Alignment.centerRight,
          child: Column(
            children: [
              LevelFilterBar(
                levelsFilterList: levelsFilterList,
                selected: state.filterBy,
                onSelected: (level) {
                  context.read<HomeCubit>().filterBy(level);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(_LessonsSelectorDelegate oldDelegate) => false;
}
