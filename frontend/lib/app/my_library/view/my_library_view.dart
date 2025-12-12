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
              delegate: LibraryHeaderDelegate(),
            ),
          ),
          SliverToBoxAdapter(child: LibraryButtons()),
        ],
      ),
    );
  }
}

