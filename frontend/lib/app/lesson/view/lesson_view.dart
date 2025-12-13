part of 'lesson_page.dart';

class LessonView extends StatefulWidget {
  const LessonView(this.lesson, {super.key});
  final Lesson lesson;

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  final LessonPlayerController _controller = LessonPlayerController();

  @override
  void initState() {
    super.initState();
    _controller.init(widget.lesson.body);
    _controller.onWordHighlighted = (index) {
      if (mounted) setState(() {});
    };
    _controller.onPlayingStateChanged = (isPlaying) {
      if (mounted) setState(() {});
    };
    _controller.onCompleted = () {
      if (mounted) setState(() {});
    };
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextSpan _buildTextSpan() {
    return TextSpan(
      children: List.generate(_controller.wordInfoList.length, (index) {
        final word = _controller.wordInfoList[index].word;
        final isHighlighted = index == _controller.currentWordIndex;
        return TextSpan(
          children: [
            TextSpan(
              text: word,
              style: BTextStyles.of(context).displaySmall.copyWith(
                color: isHighlighted ? yellow120 : grey190,
              ),
            ),
            const TextSpan(
              text: '  ', 
              style: TextStyle(decoration: TextDecoration.none),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'lessonImage-${widget.lesson.heroImage}',
              child: Image.network(
                widget.lesson.heroImage,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(color: grey140),
              ),
            ),
            Positioned(
              top: 40,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: grey0),
                onPressed: () async {
                  await _controller.stop();
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              labelColor: grey0,
              labelPadding: EdgeInsets.zero,
              labelStyle: BTextStyles.of(
                context,
              ).title1.copyWith(color: grey0),
              unselectedLabelColor: grey140,
              indicator: BoxDecoration(
                color: yellow120,
                borderRadius: BorderRadius.circular(100),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 1,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 8,
              ),
              indicatorAnimation: TabIndicatorAnimation.linear,
              splashFactory: NoSplash.splashFactory,
              dividerColor: grey110,
              dividerHeight: 0.5,
              tabs: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Tab(text: 'lesson_tab_story'.tr()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Tab(text: 'lesson_tab_quiz'.tr()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Tab(text: 'lesson_tab_keywords'.tr()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Tab(
                    text: 'lesson_tab_grammar'.tr(),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  LessonTabView(
                    lesson: widget.lesson,
                    textSpan: _buildTextSpan(),
                    isPlaying: _controller.isPlaying,
                    speak: () => _controller.speak(widget.lesson.body),
                    stop: _controller.stop,
                  ),
                  const QuizTabView(),
                  const KeywordsTabView(),
                  const GrammarTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

