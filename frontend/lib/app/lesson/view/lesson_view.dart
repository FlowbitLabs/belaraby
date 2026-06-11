part of 'lesson_page.dart';

class LessonView extends StatefulWidget {
  const LessonView(this.lesson, {super.key});
  final Lesson lesson;

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView>
    with SingleTickerProviderStateMixin {
  /// Index of the quiz tab in [_tabController].
  static const int _quizTabIndex = 1;

  late final TabController _tabController = TabController(
    length: 4,
    vsync: this,
  );

  String? _selectedWord;
  String? _translatedText;
  bool _isTranslating = false;
  String? _translationError;

  final TranslationHelper _translationHelper = TranslationHelper();

  final LessonPlayerController _controller = LessonPlayerController();
  bool _isRepeatEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller
      ..init(widget.lesson.body)
      ..onRepeat = _handleRepeat;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onWordSelected(String word) {
    setState(() {
      _selectedWord = word;
      _translatedText = null;
      _translationError = null;
    });
    _translateSelectedWord(word);
  }

  void _clearSelectedWord() {
    setState(() {
      _selectedWord = null;
      _translatedText = null;
      _translationError = null;
      _isTranslating = false;
    });
  }

  Future<void> _translateSelectedWord(String word) async {
    await _translationHelper.translateWord(
      word,
      onLoading: () {
        if (mounted) {
          setState(() {
            _isTranslating = true;
            _translationError = null;
          });
        }
      },
      onSuccess: (translatedText) {
        if (mounted) {
          setState(() {
            _translatedText = translatedText;
            _isTranslating = false;
            _translationError = null;
          });
        }
      },
      onError: (errorMessage) {
        if (mounted) {
          setState(() {
            _translationError = errorMessage;
            _isTranslating = false;
          });
        }
      },
    );
  }

  Future<void> _handleRepeat() async {
    if (_isRepeatEnabled) {
      await _controller.speak(widget.lesson.body);
      setState(() {
        _isRepeatEnabled = false;
      });
      _controller.onRepeat = _handleRepeat;
    }
  }

  void _toggleRepeat() {
    setState(() {
      _isRepeatEnabled = !_isRepeatEnabled;
    });
    _controller.onRepeat = _handleRepeat;
  }

  Future<void> _stopAndPop() async {
    await _controller.stop();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Stack(
          fit: StackFit.expand,
          children: [
            LessonHeroImage(imageUrl: widget.lesson.heroImage),
            // While the quiz tab is active the hero photo is covered by a
            // solid backdrop with the quiz progress ring centered on it.
            ListenableBuilder(
              listenable: _tabController,
              builder: (context, _) {
                final isQuizTab = _tabController.index == _quizTabIndex;
                return AnimatedOpacity(
                  opacity: isQuizTab ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !isQuizTab,
                    child: const ColoredBox(
                      color: navy140,
                      child: Center(child: QuizProgressRing()),
                    ),
                  ),
                );
              },
            ),
            // Back + learned share one row so they sit on the same line.
            // The learned toggle shows everywhere except the quiz tab,
            // whose hero is the progress backdrop.
            PositionedDirectional(
              top: 48,
              start: 16,
              end: 16,
              child: Row(
                children: [
                  LessonBackButton(onPressed: _stopAndPop),
                  const Spacer(),
                  ListenableBuilder(
                    listenable: _tabController,
                    builder: (context, _) => Visibility(
                      visible: _tabController.index != _quizTabIndex,
                      child: LearnedToggleButton(lessonId: widget.lesson.id),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              LessonTabBar(controller: _tabController),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return LessonTabView(
                          lesson: widget.lesson,
                          textSpan: _buildHighlightedText(),
                          isPlaying: _controller.isPlaying,
                          speak: () => _controller.speak(widget.lesson.body),
                          stop: _controller.stop,
                          isRepeatEnabled: _isRepeatEnabled,
                          onRepeatToggle: _toggleRepeat,
                          speedLabel: _controller.speedLabel,
                          onSpeedToggle: _controller.cycleSpeed,
                          highlightedCharIndex:
                              _controller.highlightedIndex >= 0
                              ? _controller
                                    .words[_controller.highlightedIndex]
                                    .startIndex
                              : -1,
                          onWordSelected: _onWordSelected,
                          selectedWord: _selectedWord,
                        );
                      },
                    ),
                    const QuizTabView(),
                    const KeywordsTabView(),
                    const GrammarTabView(),
                  ],
                ),
              ),
            ],
          ),
          // Floating translation card for the tapped story word: slides up
          // from the bottom over the content, sitting ABOVE the playback
          // controls (which live at bottom 50, ~58px tall) so neither
          // blocks the other.
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 120,
            child: AnimatedSlide(
              offset: _selectedWord != null
                  ? Offset.zero
                  : const Offset(0, 1.5),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _selectedWord == null
                  ? const SizedBox.shrink()
                  : WordTranslationCard(
                      word: _selectedWord!,
                      translatedText: _translatedText,
                      isTranslating: _isTranslating,
                      errorMessage: _translationError,
                      onDismissed: _clearSelectedWord,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the rich text with the currently spoken word highlighted.
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
                fontSize: 20,
                height: 1.9,
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
