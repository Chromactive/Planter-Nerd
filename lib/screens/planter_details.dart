import 'package:flutter/material.dart';
import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/models/model_fields.dart';
import 'package:planter_squared/data/models/todo.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/routes.dart';
import 'package:planter_squared/util.dart';
import 'package:planter_squared/widgets/form.dart';
import 'package:planter_squared/widgets/garden.dart';
import 'package:planter_squared/widgets/list.dart';
import 'package:planter_squared/widgets/todo.dart';
import 'package:provider/provider.dart';

class PlanterDetailScreen extends StatefulWidget {
  const PlanterDetailScreen({Key? key}) : super(key: key);

  @override
  State<PlanterDetailScreen> createState() => _PlanterDetailScreenState();
}

class _PlanterDetailScreenState extends State<PlanterDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)!.settings.arguments as PlanterArgs;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: appBar(context, goBack: true),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) => ModalTaskForm(
                      planter: args.planter,
                    ));
          }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 5 / 3,
            child: SemiCircularImage(
              borderRadius: const BorderRadius.vertical(bottom: Radius.elliptical(300, 16)),
              imageLink: args.plant?.imageLink ?? kNoImageDefault,
              linearGradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.1, 0.5, 1],
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.0),
                ],
              ),
              child: Center(
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 25,
                      child: Column(
                        children: [
                          Text(
                            args.planter.location,
                            style: textTheme.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            args.planter.name,
                            style: textTheme.headlineMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            args.plant?.plantName ?? '',
                            style: textTheme.titleLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: PlanterDetailNavigation(
            planter: args.planter,
            plant: args.plant,
          )),
        ],
      ),
    );
  }
}

class PlanterDetailNavigation extends StatefulWidget {
  const PlanterDetailNavigation({
    Key? key,
    required this.planter,
    required this.plant,
  }) : super(key: key);

  final Planter planter;
  final Plant? plant;

  @override
  State<PlanterDetailNavigation> createState() => _PlanterDetailNavigationState();
}

class _PlanterDetailNavigationState extends State<PlanterDetailNavigation> {
  late final PageController _pageController;
  int _currentIndex = 0;

  final List<String> _sections = ['Overview', 'Tasks'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            height: 45,
            child: ListView.builder(
              itemCount: _sections.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ChoiceChip(
                  selectedColor: Theme.of(context).colorScheme.surfaceTint,
                  label: Text(
                    _sections[index],
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: _currentIndex == index ? Theme.of(context).colorScheme.onSurface : null),
                  ),
                  selected: _currentIndex == index,
                  onSelected: (selected) {
                    if (selected) {
                      _onTabSelected(index);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: NoScrollIndicator(),
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                PlanterOverview(
                  planter: widget.planter,
                  plant: widget.plant,
                ),
                PlanterTaskList(
                  planter: widget.planter,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PlanterOverview extends StatelessWidget {
  const PlanterOverview({
    Key? key,
    required this.planter,
    required this.plant,
  }) : super(key: key);

  final Planter planter;
  final Plant? plant;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ScrollConfiguration(
      behavior: NoScrollIndicator(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 2.0),
            child: PictureListItem(
              height: 64.0,
              imageLink: plant?.imageLink ?? kNoImageDefault,
              content: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Nerd out about ${plant?.plantName ?? ''}',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_circle_right_outlined),
                  ],
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, Routes.plantDetails, arguments: plant);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 2.0),
            child: Text(
              'Current status',
              style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: RequirementMeasure(
                    planter: planter,
                    requirement: plant!.requirements[PlantFields.light]!,
                    measure: () => planter.lightRead,
                  ),
                ),
                Flexible(
                  child: RequirementMeasure(
                    planter: planter,
                    requirement: plant!.requirements[PlantFields.moisture]!,
                    measure: () => planter.moistureRead,
                  ),
                ),
                Flexible(
                  child: RequirementMeasure(
                    planter: planter,
                    requirement: plant!.requirements[PlantFields.temperature]!,
                    measure: () => planter.temperatureRead,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlanterTaskList extends StatelessWidget {
  const PlanterTaskList({
    Key? key,
    required this.planter,
  }) : super(key: key);

  final Planter planter;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Authentication>(context);
    return StreamBuilder<List<Task>>(
      stream: auth.authUser!.taskDatabase.streamFiltered((ref) =>
          ref.where(TaskFields.complete, isEqualTo: false).where(TaskFields.planterId, isEqualTo: planter.planterId)),
      builder: (context, stream) => TaskList(
        stream: stream,
        auth: auth,
        planter: planter,
        preventPadding: true,
      ),
    );
  }
}
