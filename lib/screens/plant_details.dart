import 'package:flutter/material.dart';
import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/models/model_fields.dart';
import 'package:planter_squared/util.dart';
import 'package:planter_squared/widgets/form.dart';
import 'package:planter_squared/widgets/garden.dart';

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final plant = ModalRoute.of(context)!.settings.arguments as Plant;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: appBar(context, goBack: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: SemiCircularImage(
                imageLink: plant.imageLink,
                borderRadius: const BorderRadius.vertical(bottom: Radius.elliptical(300, 36)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              child: PlantDetailHeader(plant: plant),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Care',
                style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(child: PlantRequirementCard(requirement: plant.requirements[PlantFields.light]!)),
                  Flexible(child: PlantRequirementCard(requirement: plant.requirements[PlantFields.moisture]!)),
                  Flexible(child: PlantRequirementCard(requirement: plant.requirements[PlantFields.temperature]!)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 4.0, left: 20.0),
              child: Text(
                'About this plant',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 20.0),
              child: Text(
                plant.description,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantDetailHeader extends StatelessWidget {
  const PlantDetailHeader({
    Key? key,
    required this.plant,
  }) : super(key: key);

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plant.plantName,
              style:
                  textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: textTheme.titleLarge?.color),
            ),
            Text(
              plant.scientificName,
              style:
                  textTheme.titleLarge!.copyWith(fontStyle: FontStyle.italic, color: textTheme.headlineMedium?.color),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => ModalPlanterForm(
                plant: plant,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(8.0),
          ),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
