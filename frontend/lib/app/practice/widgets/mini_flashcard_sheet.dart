import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/app/practice/widgets/flip_card.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Mini flashcard preview: tap-to-flip word/meaning in a bottom sheet.
Future<void> showMiniFlashcard(BuildContext context, PracticeWord word) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => MiniFlashcardSheet(word: word),
  );
}

/// Bottom-sheet content for [showMiniFlashcard].
class MiniFlashcardSheet extends StatefulWidget {
  const MiniFlashcardSheet({required this.word, super.key});

  final PracticeWord word;

  @override
  State<MiniFlashcardSheet> createState() => _MiniFlashcardSheetState();
}

class _MiniFlashcardSheetState extends State<MiniFlashcardSheet> {
  bool _revealed = false;

  Widget _face({required Color background, required Widget child}) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _revealed = !_revealed),
              child: FlipCard(
                revealed: _revealed,
                front: _face(
                  background: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.word,
                        textAlign: TextAlign.center,
                        style: BTextStyles.of(context).title1.copyWith(
                          color: grey190,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: yellow120,
                          size: 28,
                        ),
                        tooltip: 'tooltip_play'.tr(),
                        onPressed: () => WordSpeaker().speak(word.word),
                      ),
                      Text(
                        'practice_tap_to_flip'.tr(),
                        style: const TextStyle(color: grey140, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                back: _face(
                  background: yellow15,
                  child: Text(
                    word.meaning.isNotEmpty
                        ? word.meaning
                        : 'practice_no_meaning'.tr(),
                    textAlign: TextAlign.center,
                    style: BTextStyles.of(context).body1.copyWith(
                      color: grey190,
                      fontSize: 20,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
