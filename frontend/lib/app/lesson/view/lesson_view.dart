
part of 'lesson_page.dart';


class LessonView extends StatefulWidget {
  const LessonView(this.lesson, {super.key});
  final Lesson lesson;

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  String? _selectedWord;
  String? _translatedText;
  bool _isTranslating = false;
  String? _translationError;
  
  final TranslationHelper _translationHelper = TranslationHelper();
  
  void _onWordSelected(String word) {
    setState(() {
      _selectedWord = word;
      _translatedText = null;
      _translationError = null;
    });
    // Automatically translate the selected word
    _translateSelectedWord(word);
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
  final LessonPlayerController _controller = LessonPlayerController();
  bool _isRepeatEnabled = false;
  bool _isLearnt = false;

  Future<void> _handleRepeat() async {
    if (_isRepeatEnabled) {
      await _controller.speak(widget.lesson.body);
      setState(() {
        _isRepeatEnabled = false;
      });
      _controller.setRepeatCallback(_handleRepeat);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.init(widget.lesson.body);
    _controller.setRepeatCallback(_handleRepeat);
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
            if (_selectedWord != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: Dismissible(
                  key: ValueKey(_selectedWord),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {

                    setState(() {
                      _selectedWord = null;
                      _translatedText = null;
                      _translationError = null;
                      _isTranslating = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedWord!,
                                    textAlign: TextAlign.start,
                                    style: BTextStyles.of(context).title1.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Translation result display
                                  Builder(
                                    builder: (context) {
                                      if (_translatedText != null) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            _translatedText!,
                                            style: BTextStyles.of(context).body1.copyWith(
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      } else if (_isTranslating) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(strokeWidth: 1.5),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'translating'.tr(),
                                                style: BTextStyles.of(context).caption.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (_translationError != null) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                size: 12,
                                                color: Colors.red.shade600,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  _translationError!,
                                                  style: BTextStyles.of(context).caption.copyWith(
                                                    color: Colors.red.shade600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.fitness_center, size: 20),
                                  tooltip: 'Exercise',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Exercise for "$_selectedWord"')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, size: 20),
                                  tooltip: 'Play',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () {
                                    WordSpeaker().speak(_selectedWord!);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 67,
              left: 16,
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
              right: 16,
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
                        onRepeatToggle: () {
                          setState(() {
                            _isRepeatEnabled = !_isRepeatEnabled;
                          });
                          _controller.setRepeatCallback(_handleRepeat);
                        },
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
