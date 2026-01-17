part of 'lesson_page.dart';

class LessonView extends StatefulWidget {
  const LessonView(this.lesson, {super.key});
  final Lesson lesson;

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  final LessonPlayerController _controller = LessonPlayerController();
  bool _isLearnt = false;

  @override
  void initState() {
    super.initState();
    _controller.init(widget.lesson.body);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              top: 60,
              left: 15,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: grey100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: grey170, size: 20),
                  onPressed: () async {
                    await _controller.stop();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  tooltip: 'back',
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: 10,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLearnt = !_isLearnt;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLearnt ? yellow120 : Colors.white,
                    foregroundColor: _isLearnt ? Colors.white : yellow120,
                    shape: const StadiumBorder(),
                    side: BorderSide(color: yellow120, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    elevation: _isLearnt ? 2 : 0,
                    shadowColor: _isLearnt ? green100.withOpacity(0.2) : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'lesson_learnt_button'.tr(),
                        style: TextStyle(
                          color: _isLearnt ? Colors.white : yellow120,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isLearnt ? Icons.check_circle : Icons.check_circle_outline,
                        color: _isLearnt ? Colors.white : yellow120,
                        size: 22,
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // ... (TabBar setup omitted for brevity, assuming standard Flutter TabBar) ...
            TabBar(
              labelColor: grey0,
              labelPadding: EdgeInsets.zero,
              labelStyle: BTextStyles.of(context).title1.copyWith(color: grey0),
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
                _buildTab('lesson_tab_story'.tr()),
                _buildTab('lesson_tab_quiz'.tr()),
                _buildTab('lesson_tab_keywords'.tr()),
                _buildTab('lesson_tab_grammar'.tr()),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // TAB 1: STORY & PLAYER
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return LessonTabView(
                        lesson: widget.lesson,
                        textSpan: _buildHighlightedText(),
                        isPlaying: _controller.isPlaying,
                        speak: () => _controller.speak(widget.lesson.body),
                        stop: _controller.stop,
                      );
                    },
                  ),
                  // Other Tabs
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

  /// Helper to build a consistent Tab widget
  Widget _buildTab(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Tab(text: text),
    );
  }

  /// Builds the rich text with the current word highlighted.
  TextSpan _buildHighlightedText() {
    return TextSpan(
      children: List.generate(_controller.words.length, (index) {
        final info = _controller.words[index];
        final isHighlighted = index == _controller.highlightedIndex;

        return TextSpan(
          children: [
            TextSpan(
              text: info.word,
              style: BTextStyles.of(context).displaySmall.copyWith(
                color: isHighlighted ? yellow120 : grey190,
              ),
            ),
            // Add a non-highlighted space after each word
            const TextSpan(
              text: '  ',
              style: TextStyle(decoration: TextDecoration.none),
            ),
          ],
        );
      }),
    );
  }
}
