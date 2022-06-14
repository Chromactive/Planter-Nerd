import 'package:flutter/material.dart';
import 'package:planter_squared/widgets/garden.dart';
import 'package:planter_squared/widgets/todo.dart';

class PlanterDashboard extends StatelessWidget {
  const PlanterDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
          flex: 6,
          child: PlanterListView(),
        ),
        Flexible(
          flex: 7,
          child: TaskListView(),
        ),
      ],
    );
  }
}
