import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/models/model_fields.dart';
import 'package:planter_squared/data/models/todo.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/util.dart';
import 'package:planter_squared/widgets/list.dart';
import 'package:planter_squared/widgets/text.dart';
import 'package:provider/provider.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({
    Key? key,
  }) : super(key: key);

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<Authentication>(
      builder: (context, auth, _) => StreamBuilder<List<Task>>(
        stream: auth.authUser!.taskDatabase.streamFiltered((ref) => ref.where(TaskFields.complete, isEqualTo: false)),
        builder: (context, stream) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 24.0, bottom: 8.0),
              child: Superscript(
                base: Text('${auth.authUser?.name ?? 'My'} Tasks'),
                color: Colors.black,
                superscript:
                    Text(stream.connectionState == ConnectionState.waiting ? '' : '${stream.data?.length ?? 0}'),
                baseStyle: textTheme.headlineMedium?.apply(fontWeightDelta: 1),
                superscriptStyle: textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: TaskList(
                auth: auth,
                stream: stream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList(
      {Key? key,
      required this.stream,
      required this.auth,
      this.planter,
      this.preventPadding = false,
      this.filters = const ['Today', 'Late', 'Watering', 'Sunlight', 'Temperature']})
      : super(key: key);

  final List<String> filters;
  final AsyncSnapshot<List<Task>> stream;
  final Authentication auth;
  final Planter? planter;
  final bool preventPadding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: SizedBox(
            height: 35,
            child: Filters(
              filters: filters,
              onFiltersChange: (f) {},
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (stream.connectionState == ConnectionState.waiting) {
                return loadingScreen();
              }
              final tasks = stream.data ?? [];
              if (tasks.isEmpty) {
                return Center(
                  child: Text(
                    'You have no tasks!',
                    style: textTheme.titleLarge?.copyWith(color: textTheme.headlineMedium?.color),
                  ),
                );
              }
              return ListView.builder(
                padding: preventPadding ? EdgeInsets.zero : null,
                itemCount: tasks.length,
                itemBuilder: (context, index) => TaskListItem(
                  auth: auth,
                  task: tasks[index],
                  planter: planter,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TaskListItem extends StatefulWidget {
  const TaskListItem({
    Key? key,
    required this.task,
    required this.auth,
    this.planter,
  }) : super(key: key);

  final Task task;
  final Authentication auth;
  final Planter? planter;

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  bool _expanded = false;

  void _togglePanel() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  Widget _build(Planter? planter) {
    return Column(
      children: [
        PictureListItem(
          onTap: _togglePanel,
          height: 72.0,
          color: widget.task.requirementType.color,
          leading: Center(
            child: Icon(
              widget.task.requirementType.feedIcon,
              color: Colors.white.withOpacity(0.5),
              size: 48,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planter?.name ?? 'Planter',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        planter?.location ?? '',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        widget.task.description ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 18,
                    ),
                    Text(
                      widget.task.date,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const Icon(
                      CupertinoIcons.clock,
                      size: 18,
                    ),
                    Text(
                      widget.task.time,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ExpandedSection(
          expand: _expanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        widget.auth.authUser!.taskDatabase.deleteEntry(widget.task.taskId);
                      },
                      child: const Icon(Icons.cancel),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        widget.auth.authUser!.taskDatabase
                            .updateEntry({TaskFields.complete: true}, id: widget.task.taskId);
                      },
                      child: const Icon(Icons.check),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.planter != null
        ? _build(widget.planter)
        : StreamBuilder<Planter?>(
            stream: widget.auth.authUser!.planterDatabase.streamSingle(widget.task.planterId),
            builder: (context, stream) => _build(stream.data),
          );
  }
}
