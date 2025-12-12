import 'package:belaraby/app/home/cubit/home_cubit.dart';
import 'package:belaraby/app/home/cubit/home_state.dart';
import 'package:belaraby/app/home/widgets/filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonFilterDelegate extends SliverPersistentHeaderDelegate {
  const LessonFilterDelegate();

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Container(
          color: const Color.fromARGB(255, 241, 241, 241),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          alignment: Alignment.centerRight,
          child: Column(
            children: [
              LevelFilterBar(
                levelsFilterList: levelsFilterList,
                selected: state.filterBy,
                onSelected: (level) {
                  context.read<HomeCubit>().filterBy(level);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(LessonFilterDelegate oldDelegate) => false;
}
