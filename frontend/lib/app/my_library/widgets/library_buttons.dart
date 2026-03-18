import 'package:belaraby/app/my_library/cubit/my_library_cubit.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibraryButtons extends StatelessWidget {
  const LibraryButtons({super.key});

  String _calculateItems(int items) {
    if (items < 1) return 'لا توجد عناصر';
    if (items == 1) return 'عنصر واحد';
    if (items == 2) return 'عنصران';
    final arabicDigits = convertToArabicDigits(number: items);
    if (items >= 3 && items <= 10) return '$arabicDigits عناصر';
    if (items >= 11 && items < 100) return '$arabicDigits عنصراً';
    return '$arabicDigits عنصر';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyLibraryCubit, MyLibraryState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildLibraryButton(
                context,
                label: 'library_favorites'.tr(),
                itemCount: _calculateItems(state.favorites.length),
                trailingIcon: Icons.favorite_border,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              _buildLibraryButton(
                context,
                label: 'library_learned_stories'.tr(),
                itemCount: _calculateItems(state.learnedLessons.length),
                trailingIcon: Icons.library_add_check,
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLibraryButton(
    BuildContext context, {
    required String label,
    required IconData trailingIcon,
    required VoidCallback onPressed,
    required String itemCount,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 5),
              child: Icon(trailingIcon, size: 40, color: Colors.yellow[800]),
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
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
