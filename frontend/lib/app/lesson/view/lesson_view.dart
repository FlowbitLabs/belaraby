part of 'lesson_page.dart';

class LessonView extends StatefulWidget {
  const LessonView(this.lesson, {super.key});
  final Lesson lesson;

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  final FlutterTts flutterTts = FlutterTts();

  late final List<WordInfo> wordInfoList;
  int currentWordIndex = -1;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    wordInfoList = _splitText(widget.lesson.body);
    _initTts();
  }

  List<WordInfo> _splitText(String text) {
    final regex = RegExp(r'\S+');
    return regex
        .allMatches(text)
        .map((m) => WordInfo(m.group(0)!, m.start))
        .toList();
  }

  void _updateState({bool? playing, int? wordIndex}) {
    setState(() {
      if (playing != null) isPlaying = playing;
      if (wordIndex != null) currentWordIndex = wordIndex;
    });
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('ar');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.awaitSpeakCompletion(true);

    flutterTts
      ..setProgressHandler((_, start, _, _) {
        final index = wordInfoList.indexWhere(
          (w) => start >= w.start && start < w.start + w.word.length,
        );
        if (index != -1 && index != currentWordIndex) {
          _updateState(wordIndex: index);
        }
      })
      ..setStartHandler(() => _updateState(playing: true))
      ..setCompletionHandler(() => _updateState(playing: false, wordIndex: -1))
      ..setErrorHandler((_) => _updateState(playing: false, wordIndex: -1));
  }

  Future<void> _speak() async {
    if (isPlaying) {
      await _stop();
    } else {
      await flutterTts.speak(widget.lesson.body);
      _updateState(playing: true);
    }
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    _updateState(playing: false, wordIndex: -1);
  }

  TextSpan _buildTextSpan() {
    return TextSpan(
      children: List.generate(wordInfoList.length, (index) {
        final word = wordInfoList[index].word;
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
                  await _stop();
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
                    speak: _speak,
                    stop: _stop,
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

class WordInfo {
  WordInfo(this.word, this.start);
  final String word;
  final int start;
}
