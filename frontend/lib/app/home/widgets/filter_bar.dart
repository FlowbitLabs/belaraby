import 'package:belaraby/app/util/get_level_color.dart';
import 'package:flutter/material.dart';

class LevelFilterBar extends StatefulWidget {
  const LevelFilterBar({
    required this.levelsFilterList,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> levelsFilterList;
  final String selected;
  final void Function(String level) onSelected;

  @override
  State<LevelFilterBar> createState() => _LevelFilterBarState();
}

class _LevelFilterBarState extends State<LevelFilterBar> {
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    for (final level in widget.levelsFilterList) {
      _itemKeys[level] = GlobalKey();
    }
  }

  void _onTap(String level) {
    widget.onSelected(level);

    final key = _itemKeys[level];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        alignment: 0.1,

        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.levelsFilterList.map((level) {
          final isSelected = widget.selected == level;
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              key: _itemKeys[level],
              decoration: BoxDecoration(
                color: isSelected ? getFilterColor(level) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _onTap(level),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      level,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
