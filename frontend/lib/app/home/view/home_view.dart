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
            // Cold start: nothing fetched yet.
            if (state.lessons.isEmpty &&
                (state.status == HomeStatus.loading ||
                    state.status == HomeStatus.initial)) {
              return const Center(
                child: CircularProgressIndicator(color: yellow120),
              );
            }
            if (state.status == HomeStatus.error && state.lessons.isEmpty) {
              return const _HomeError();
            }
            if (state.status == HomeStatus.success && state.lessons.isEmpty) {
              return Center(child: Text('home_no_lessons'.tr()));
            }

            return RefreshIndicator(
              color: yellow120,
              onRefresh: () => context.read<HomeCubit>().getLessons(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const SliverSafeArea(
                    sliver: SliverPersistentHeader(
                      pinned: true,
                      delegate: HomeHeaderDelegate(),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'home_filter'.tr(args: [state.filterBy.tr()]),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          _HideLearnedButton(isActive: state.hideLearned),
                        ],
                      ),
                    ),
                  ),
                  const SliverPersistentHeader(
                    pinned: true,
                    delegate: LessonFilterDelegate(),
                  ),
                  SliverToBoxAdapter(
                    child: LessonsSection(
                      lessons: state.paidLessonsBySelectedLevel,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'home_load_error'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow120,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () => context.read<HomeCubit>().getLessons(),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggles the learned-lessons filter; highlighted while active.
class _HideLearnedButton extends StatelessWidget {
  const _HideLearnedButton({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final foreground = isActive ? Colors.white : Colors.black;
    return TextButton(
      onPressed: () => context.read<HomeCubit>().toggleHideLearned(),
      style: TextButton.styleFrom(
        backgroundColor: isActive ? yellow120 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'home_hide_learnt'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: foreground,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isActive ? Icons.check_circle : Icons.check_circle_outline_outlined,
            color: foreground,
            size: 18,
          ),
        ],
      ),
    );
  }
}
