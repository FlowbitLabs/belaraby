import 'package:belaraby/app/my_library/cubit/my_library_cubit.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_library_view.dart';

class MyLibraryPage extends StatelessWidget {
  const MyLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyLibraryCubit(),
      child: const MyLibraryView(),
    );
  }
}
