import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/data/util/constants.dart';
import 'package:planter_squared/routes.dart';
import 'package:planter_squared/util.dart';
import 'package:planter_squared/widgets/form.dart';
import 'package:planter_squared/widgets/list.dart';
import 'package:planter_squared/widgets/text.dart';
import 'package:provider/provider.dart';

class PlantRequirementIcon extends StatelessWidget {
  const PlantRequirementIcon({
    Key? key,
    required this.requirement,
  }) : super(key: key);

  final Requirement requirement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: requirement.type.color,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(requirement.type.baseIcon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class PlantRequirementCard extends StatelessWidget {
  const PlantRequirementCard({
    Key? key,
    required this.requirement,
  }) : super(key: key);

  final Requirement requirement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Icon(
                requirement.type.baseIcon,
                color: requirement.type.color,
                size: 32.0,
              ),
            ),
            Text(
              requirement.comment.capitalize(),
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              requirement.rangeToText(),
              style: textTheme.labelMedium!.apply(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.calendar_month, size: 20.0),
                    ),
                    TextSpan(text: requirement.frequency.capitalize()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequirementMeasure extends StatefulWidget {
  const RequirementMeasure({
    Key? key,
    required this.planter,
    required this.requirement,
    required this.measure,
  }) : super(key: key);

  final Planter planter;
  final Requirement requirement;
  final double Function() measure;

  @override
  State<RequirementMeasure> createState() => _RequirementMeasureState();
}

class _RequirementMeasureState extends State<RequirementMeasure> {
  bool _isAutomated = false;

  void _onMeasureChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getIsAutomated();
    widget.planter.onMeasureChange.add(_onMeasureChange);
  }

  @override
  void dispose() {
    widget.planter.onMeasureChange.removeLast();
    super.dispose();
  }

  void _getIsAutomated() async {
    _isAutomated = ((await FirebaseDatabase.instance
                .ref(DatabaseConstants.measureCollections)
                .child(widget.planter.planterId)
                .child(widget.requirement.measurePath)
                .get())
            .value ??
        false) as bool;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.75,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Icon(
                        widget.requirement.type.baseIcon,
                        color: widget.requirement.type.color,
                        size: 32.0,
                      ),
                    ),
                    Text(
                      widget.requirement.comment,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${widget.measure().toStringAsFixed(2)} ${widget.requirement.unit}',
                      style:
                          Theme.of(context).textTheme.labelLarge!.apply(color: Theme.of(context).colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.requirement.type.minIcon,
                          size: 18,
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            backgroundColor: Theme.of(context).dividerColor,
                            value: widget.requirement.range.convertToRelative(widget.measure()),
                          ),
                        ),
                        Icon(
                          widget.requirement.type.maxIcon,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: ElevatedButton(
              onPressed: () async {
                _isAutomated = await widget.requirement.toggleMode(
                  widget.planter.planterId,
                );
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero, // Set this
                padding: const EdgeInsets.all(8.0), // and this
              ),
              child: Icon(_isAutomated ? Icons.front_hand : Icons.computer),
            ),
          ),
        ],
      ),
    );
  }
}

class PlanterListView extends StatefulWidget {
  const PlanterListView({Key? key}) : super(key: key);

  @override
  State<PlanterListView> createState() => _PlanterListViewState();
}

class _PlanterListViewState extends State<PlanterListView> {
  List<Planter> _selectedForDeletion = [];
  bool _longPressFlag = false;

  void _longPress() {
    setState(() {
      _longPressFlag = _selectedForDeletion.isNotEmpty;
    });
  }

  void _addPlanter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ModalPlanterForm(),
    );
  }

  void _deletePlanter(Planter planter) {
    final auth = Provider.of<Authentication>(context, listen: false);
    List<String> tasks = planter.taskIds;
    for (final task in tasks) {
      auth.authUser!.taskDatabase.deleteEntry(task);
    }
    auth.authUser!.planterDatabase.deleteEntry(planter.planterId);
  }

  void _deletePlanters() {
    for (final planter in _selectedForDeletion) {
      _deletePlanter(planter);
    }
    setState(() {
      _selectedForDeletion = [];
      _longPressFlag = false;
    });
  }

  void _addOrDelete() {
    if (_selectedForDeletion.isEmpty) {
      _addPlanter();
    } else {
      _deletePlanters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<Authentication>(
      builder: (context, auth, _) => StreamBuilder<List<Planter>>(
        stream: auth.authUser!.planterDatabase.streamCollection(),
        builder: (context, stream) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Superscript(
                      base: Text('${auth.authUser?.name ?? 'My'} Planters'),
                      color: Colors.black,
                      superscript:
                          Text(stream.connectionState == ConnectionState.waiting ? '' : '${stream.data?.length ?? 0}'),
                      baseStyle: Theme.of(context).textTheme.headlineMedium?.apply(fontWeightDelta: 1),
                      superscriptStyle: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _addOrDelete,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(8.0),
                    ),
                    child: _selectedForDeletion.isEmpty
                        ? const Icon(Icons.add)
                        : Superscript(
                            base: const Icon(Icons.delete),
                            superscript: Text(_selectedForDeletion.length == 1 ? '' : '${_selectedForDeletion.length}'),
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 4.0),
              child: MaterialSearchBar(hintText: 'Search...', onSearchConfirm: (criteria) {}),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: NoScrollIndicator(),
                child: Builder(
                  builder: (conext) {
                    if (stream.connectionState == ConnectionState.waiting) {
                      return loadingScreen();
                    }
                    final planters = stream.data ?? [];
                    if (planters.isEmpty) {
                      return Center(
                        child: Text(
                          'You have no planters!',
                          style: textTheme.titleLarge?.copyWith(color: textTheme.headlineMedium?.color),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: planters.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: StreamBuilder<Plant?>(
                          stream: planters[index].plant,
                          builder: (context, snapshot) => PlanterCard(
                            planter: planters[index],
                            plant: snapshot.data,
                            index: index,
                            longPressEnabled: _longPressFlag,
                            onItemToggled: () {
                              if (_selectedForDeletion.any((p) => p.planterId == planters[index].planterId)) {
                                _selectedForDeletion.removeWhere((p) => p.planterId == planters[index].planterId);
                              } else {
                                _selectedForDeletion.add(planters[index]);
                              }
                              _longPress();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanterArgs {
  const PlanterArgs({
    required this.planter,
    required this.plant,
  });

  final Planter planter;
  final Plant? plant;
}

class PlanterCard extends StatefulWidget {
  const PlanterCard({
    Key? key,
    required this.planter,
    required this.plant,
    required this.index,
    required this.onItemToggled,
    required this.longPressEnabled,
  }) : super(key: key);

  final Planter planter;
  final Plant? plant;
  final int index;
  final void Function() onItemToggled;
  final bool longPressEnabled;

  @override
  State<PlanterCard> createState() => _PlanterCardState();
}

class _PlanterCardState extends State<PlanterCard> {
  bool _selected = false;

  void _onMeasureChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.planter.onMeasureChange.add(_onMeasureChange);
  }

  @override
  void dispose() {
    widget.planter.onMeasureChange.removeLast();
    super.dispose();
  }

  void _tap() {
    if (widget.longPressEnabled) {
      setState(() {
        _selected = !_selected;
      });
      widget.onItemToggled();
    } else {
      Navigator.pushNamed(context, Routes.planterDetails,
          arguments: PlanterArgs(planter: widget.planter, plant: widget.plant));
    }
  }

  void _longPress() {
    setState(() {
      _selected = !_selected;
    });
    widget.onItemToggled();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 2.5 / 3,
      child: Stack(
        children: [
          Positioned.fill(
            left: 8,
            child: InkResponse(
              borderRadius: BorderRadius.circular(16.0),
              highlightShape: BoxShape.rectangle,
              onTap: Feedback.wrapForTap(_tap, context),
              onLongPress: Feedback.wrapForLongPress(_longPress, context),
              child: Card(
                borderOnForeground: true,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: _selected ? BorderSide(color: colorScheme.primary, width: 2.5) : BorderSide.none,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          image: widget.plant == null
                              ? null
                              : DecorationImage(
                                  image: NetworkImage(widget.plant!.imageLink),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.2, 0.35, 0.6],
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(widget.planter.hasWarning(widget.plant) ? 16.0 : 8.0, 0.0, 8.0, 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (widget.planter.taskIds.isNotEmpty)
                                  Superscript(
                                    base: const Icon(
                                      Icons.task_alt,
                                      size: 18.0,
                                    ),
                                    superscript: Text('${widget.planter.taskIds.length}'),
                                  ),
                              ],
                            ),
                            Text(
                              widget.planter.name,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineSmall,
                            ),
                            Text('${widget.plant?.plantName ?? ''} • ${widget.planter.location}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: (widget.plant != null ? widget.planter.getWarningRequirements(widget.plant!) : [])
                    .map((r) => PlantRequirementIcon(
                          requirement: r,
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
