import 'package:flutter/material.dart';
import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/repos.dart';
import 'package:planter_squared/routes.dart';
import 'package:planter_squared/util.dart';
import 'package:planter_squared/widgets/form.dart';
import 'package:planter_squared/widgets/list.dart';

class PlantListScreen extends StatelessWidget {
  const PlantListScreen({
    Key? key,
    this.goToDetails = true,
    this.doNavigation = true,
  }) : super(key: key);

  final bool goToDetails;
  final bool doNavigation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            'Find a plant',
            style: textTheme.headlineMedium?.apply(
              fontWeightDelta: 1,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: MaterialSearchBar(
            hintText: 'Search...',
            onSearchConfirm: (criteria) {},
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: StreamBuilder<List<Plant>>(
              stream: plantDatabase.streamCollection(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loadingScreen();
                }
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) => PlantListItem(
                    item: snapshot.data![index],
                    goToDetails: goToDetails,
                    doNavigation: doNavigation,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class PlantListItem extends StatelessWidget {
  const PlantListItem({
    Key? key,
    required this.item,
    required this.doNavigation,
    this.goToDetails = true,
    this.onTapped,
  }) : super(key: key);

  final Plant item;
  final bool doNavigation;
  final bool goToDetails;
  final void Function(Plant plant)? onTapped;

  @override
  Widget build(BuildContext context) {
    return PictureListItem(
      onTap: () {
        onTapped?.call(item);
        if (doNavigation) {
          if (goToDetails) {
            Navigator.pushNamed(context, Routes.plantDetails, arguments: item);
          } else {
            Navigator.pop<Plant>(context, item);
          }
        }
      },
      height: 96.0,
      imageLink: item.imageLink,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.plantName,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.scientificName,
                style: Theme.of(context).textTheme.labelLarge?.apply(fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Expanded(
            child: Text(
              item.description,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
