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
            _LessonHeroImage(imageUrl: widget.lesson.heroImage),
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
                  _LessonBackButton(onPressed: _stopAndPop),
                  const Spacer(),
                  ListenableBuilder(
                    listenable: _tabController,
                    builder: (context, _) => Visibility(
                      visible: _tabController.index != _quizTabIndex,
                      child: _LearnedToggleButton(lessonId: widget.lesson.id),
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
              _LessonTabBar(controller: _tabController),
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
                  : _WordTranslationCard(
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

class _LessonHeroImage extends StatelessWidget {
  const _LessonHeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'lessonImage-$imageUrl',
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: grey140),
      ),
    );
  }
}

/// Floating card showing the tapped word with its English translation.
class _WordTranslationCard extends StatelessWidget {
  const _WordTranslationCard({
    required this.word,
    required this.translatedText,
    required this.isTranslating,
    required this.errorMessage,
    required this.onDismissed,
  });

  final String word;
  final String? translatedText;
  final bool isTranslating;
  final String? errorMessage;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(word),
      onDismissed: (_) => onDismissed(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: grey110),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word,
                    textAlign: TextAlign.start,
                    style: BTextStyles.of(context).title1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  _TranslationStatusLine(
                    translatedText: translatedText,
                    isTranslating: isTranslating,
                    errorMessage: errorMessage,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 20),
              tooltip: 'tooltip_play'.tr(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => WordSpeaker().speak(word),
            ),
            // Add the tapped story word to the practice deck (stored on
            // this device; the translation becomes the card meaning).
            Builder(
              builder: (context) {
                final isInPractice = context.select(
                  (PracticeCubit cubit) =>
                      cubit.state.customWords.contains(word),
                );
                return IconButton(
                  icon: Icon(
                    isInPractice
                        ? Icons.bookmark_added
                        : Icons.bookmark_add_outlined,
                    size: 20,
                    color: isInPractice ? green115 : grey160,
                  ),
                  tooltip: isInPractice
                      ? 'practice_remove_tooltip'.tr()
                      : 'practice_add_tooltip'.tr(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => context
                      .read<PracticeCubit>()
                      .toggleCustomWord(word, translatedText ?? ''),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Result line of the word translation: the translated text, a progress
/// indicator while translating, or the error message.
class _TranslationStatusLine extends StatelessWidget {
  const _TranslationStatusLine({
    required this.translatedText,
    required this.isTranslating,
    required this.errorMessage,
  });

  final String? translatedText;
  final bool isTranslating;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (translatedText != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          translatedText!,
          style: BTextStyles.of(context).body1.copyWith(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    if (isTranslating) {
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
              style: BTextStyles.of(
                context,
              ).caption.copyWith(color: grey160),
            ),
          ],
        ),
      );
    }
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 12, color: red130),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                errorMessage!,
                style: BTextStyles.of(
                  context,
                ).caption.copyWith(color: red130),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _LessonBackButton extends StatelessWidget {
  const _LessonBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(color: grey100, shape: BoxShape.circle),
      child: IconButton(
        // Icons.arrow_back auto-mirrors with the text direction, so it
        // points "back" in both RTL and LTR locales.
        icon: const Icon(Icons.arrow_back, color: grey170, size: 20),
        onPressed: onPressed,
        tooltip: 'tooltip_back'.tr(),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// Marks the lesson as learned (or unlearned) via the global [LearnedCubit];
/// failures surface as a snackbar after the optimistic toggle is reverted.
class _LearnedToggleButton extends StatelessWidget {
  const _LearnedToggleButton({required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LearnedCubit, LearnedState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage.isNotEmpty,
      listener: (context, learnedState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(learnedState.errorMessage.tr())),
        );
      },
      builder: (context, learnedState) {
        final isLearnt = learnedState.isLearned(lessonId);
        // Learnt = success green, not-yet = neutral white pill on the hero
        // photo. AnimatedContainer makes the toggle feel responsive.
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => context.read<LearnedCubit>().toggleLearned(lessonId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isLearnt
                    ? green115
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              // RTL: the icon is the LAST child so the checkmark renders
              // on the left of the label.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'lesson_learnt_button'.tr(),
                    style: TextStyle(
                      color: isLearnt ? Colors.white : grey180,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isLearnt ? Icons.check_circle : Icons.check_circle_outline,
                    color: isLearnt ? Colors.white : grey160,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LessonTabBar extends StatelessWidget {
  const _LessonTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    // Cairo with evenly distributed leading keeps the label optically
    // centered inside the pill — Arabic fonts reserve far more ascent than
    // descent, which otherwise pushes the glyphs off-center.
    const labelStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
      color: grey0,
    );
    return TabBar(
      controller: controller,
      labelColor: grey0,
      labelPadding: EdgeInsets.zero,
      labelStyle: labelStyle,
      unselectedLabelColor: grey140,
      unselectedLabelStyle: labelStyle,
      indicator: BoxDecoration(
        color: yellow120,
        borderRadius: BorderRadius.circular(100),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 1,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      indicatorAnimation: TabIndicatorAnimation.linear,
      splashFactory: NoSplash.splashFactory,
      dividerColor: grey110,
      dividerHeight: 0.5,
      tabs: [
        _LessonTab(label: 'lesson_tab_story'.tr()),
        _LessonTab(label: 'lesson_tab_quiz'.tr()),
        _LessonTab(label: 'lesson_tab_keywords'.tr()),
        _LessonTab(label: 'lesson_tab_grammar'.tr()),
      ],
    );
  }
}

class _LessonTab extends StatelessWidget {
  const _LessonTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Tab(
        height: 46,
        child: Center(child: Text(label, textAlign: TextAlign.center)),
      ),
    );
  }
}
