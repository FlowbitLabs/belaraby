part of 'my_library_page.dart';

class MyLibraryView extends StatelessWidget {
  const MyLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: MultiBlocListener(
        listeners: [
          // Keep the library in sync when favorites are toggled anywhere.
          // syncCount only changes once the backend write has settled;
          // listening on the (optimistic) favoriteIds change instead would
          // race the in-flight write and could refetch pre-write data.
          BlocListener<FavoriteCubit, FavoriteState>(
            listenWhen: (previous, current) =>
                previous.syncCount != current.syncCount,
            listener: (context, _) =>
                context.read<MyLibraryCubit>().loadLibrary(),
          ),
          BlocListener<MyLibraryCubit, MyLibraryState>(
            listenWhen: (previous, current) =>
                previous.error != current.error && current.error.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error.tr())),
              );
            },
          ),
        ],
        child: RefreshIndicator(
          color: yellow120,
          onRefresh: () => context.read<MyLibraryCubit>().loadLibrary(),
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverSafeArea(
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: LibraryHeaderDelegate(),
                ),
              ),
              SliverToBoxAdapter(child: LibraryButtons()),
              LibraryLessonList(),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
