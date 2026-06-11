import 'package:belaraby/app/my_library/cubit/my_library_cubit.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibraryButtons extends StatelessWidget {
  const LibraryButtons({super.key});

  String _itemCountLabel(BuildContext context, int items) {
    final count = context.locale.languageCode == 'ar'
        ? convertToArabicDigits(number: items)
        : items.toString();
    return 'library_items_count'.plural(items, args: [count]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyLibraryCubit, MyLibraryState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _LibraryButton(
                label: 'library_favorites'.tr(),
                itemCount: _itemCountLabel(context, state.favorites.length),
                trailingIcon: Icons.favorite_border,
                isSelected: state.section == MyLibrarySection.favorites,
                onPressed: () => context.read<MyLibraryCubit>().selectSection(
                  MyLibrarySection.favorites,
                ),
              ),
              const SizedBox(height: 12),
              _LibraryButton(
                label: 'library_learned_stories'.tr(),
                itemCount: _itemCountLabel(
                  context,
                  state.learnedLessons.length,
                ),
                trailingIcon: Icons.library_add_check,
                isSelected: state.section == MyLibrarySection.learned,
                onPressed: () => context.read<MyLibraryCubit>().selectSection(
                  MyLibrarySection.learned,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LibraryButton extends StatelessWidget {
  const _LibraryButton({
    required this.label,
    required this.itemCount,
    required this.trailingIcon,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final String itemCount;
  final IconData trailingIcon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? const BorderSide(color: yellow120, width: 2)
                : BorderSide.none,
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 18, end: 5),
              child: Icon(trailingIcon, size: 40, color: yellow120),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    itemCount,
                    style: const TextStyle(fontSize: 14, color: grey140),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 20,
                color: isSelected ? yellow120 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
