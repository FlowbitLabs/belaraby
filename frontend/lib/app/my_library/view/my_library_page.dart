import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/my_library/cubit/my_library_cubit.dart';
import 'package:belaraby/app/my_library/widgets/library_buttons.dart';
import 'package:belaraby/app/my_library/widgets/library_header_delegate.dart';
import 'package:belaraby/app/my_library/widgets/library_lesson_list.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_library_view.dart';

class MyLibraryPage extends StatelessWidget {
  const MyLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyLibraryCubit()..loadLibrary(),
      child: const MyLibraryView(),
    );
  }
}
