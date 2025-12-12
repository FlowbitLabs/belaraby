part of 'lesson_page.dart';

class LessonView extends StatefulWidget {
  const LessonView(this.lesson, {super.key});
  final Lesson lesson;

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  final LessonPlayerController _controller = LessonPlayerController();
  
  // UI State
  int currentWordIndex = -1;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    // Determine word list first so we can build UI immediately if needed
    // But here we rely on the controller to parse it.
    await _controller.init(widget.lesson.body);
    
    // Set up listeners
    _controller.onWordHighlighted = (index) {
      if (mounted) setState(() => currentWordIndex = index);
    };
    
    _controller.onPlayingStateChanged = (playing) {
      if (mounted) setState(() => isPlaying = playing);
    };
    
    _controller.onCompleted = () {
       if (mounted) {
         setState(() {
           isPlaying = false;
           currentWordIndex = -1;
         });
       }
    };
    
    // Initial build update
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextSpan _buildTextSpan() {
    final words = _controller.wordInfoList;
    if (words.isEmpty) {
      // Fallback if not initialized yet or empty
       return TextSpan(
        text: widget.lesson.body,
        style: BTextStyles.of(context).displaySmall.copyWith(color: grey190),
      );
    }

    return TextSpan(
      children: List.generate(words.length, (index) {
        final word = words[index].word;
        final isHighlighted = index == currentWordIndex;
        return TextSpan(
          children: [
            TextSpan(
              text: word,
              style: BTextStyles.of(context).displaySmall.copyWith(
                color: isHighlighted ? yellow120 : grey190,
              ),
            ),
            const TextSpan(
              text: '  ', // space without underline
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
                    isPlaying: isPlaying,
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

