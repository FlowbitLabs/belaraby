import 'dart:ui';
import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

class LessonControls extends StatelessWidget {
  const LessonControls({
    required this.isPlaying,
    required this.onPlay,
    required this.onStop,
    required this.isRepeatEnabled,
    required this.onRepeatToggle,
    required this.speedLabel,
    required this.onSpeedToggle,
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final bool isRepeatEnabled;
  final VoidCallback onRepeatToggle;

  /// Display label of the current playback speed (e.g. `١×`).
  final String speedLabel;
  final VoidCallback onSpeedToggle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: grey115.withAlpha(90), // translucent layer
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SpeedButton(label: speedLabel, onPressed: onSpeedToggle),
                    const SizedBox(width: 16),
                    IconButton.filled(
                      onPressed: onRepeatToggle,
                      style: IconButton.styleFrom(
                        backgroundColor: isRepeatEnabled
                            ? navy110
                            : grey140,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.repeat, size: 22),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filled(
                      onPressed: onStop,
                      style: IconButton.styleFrom(
                        backgroundColor: navy140,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.stop, size: 22),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filled(
                      onPressed: onPlay,
                      style: IconButton.styleFrom(
                        backgroundColor: isPlaying ? yellow140 : yellow120,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        elevation: 2,
                      ),
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular button cycling the playback speed; shows the current speed
/// (Arabic digits) as its label.
class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: grey140,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFamily: 'Cairo',
                height: 1,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
