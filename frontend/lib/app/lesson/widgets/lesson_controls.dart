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
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final bool isRepeatEnabled;
  final VoidCallback onRepeatToggle;

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
                    IconButton.filled(
                      onPressed: onRepeatToggle,
                      style: IconButton.styleFrom(
                        backgroundColor: isRepeatEnabled ? Colors.blueAccent : Colors.grey,
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
                        backgroundColor: Colors.redAccent,
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
                        backgroundColor:
                            isPlaying ? Colors.orangeAccent : Colors.green,
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
