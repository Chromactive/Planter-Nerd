import 'package:flutter/material.dart';
import 'package:planter_squared/util.dart';

class PictureListItem extends StatelessWidget {
  const PictureListItem({
    Key? key,
    this.height = 56.0,
    required this.content,
    this.imageLink,
    this.color,
    this.leading,
    this.onTap,
    this.onLongPress,
  })  : assert(imageLink != null || leading != null),
        super(key: key);

  final double height;
  final Widget content;
  final Widget? leading;
  final String? imageLink;
  final Color? color;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: Feedback.wrapForTap(() => onTap?.call(), context),
      onLongPress: Feedback.wrapForLongPress(() => onLongPress?.call(), context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: Row(children: [
            Flexible(
              flex: 3,
              child: SemiCircularImage(
                borderRadius: const BorderRadius.horizontal(right: Radius.elliptical(4, 32)),
                imageLink: imageLink,
                color: color,
                child: leading,
              ),
            ),
            Flexible(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: content,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class NoScrollIndicator extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class Filters extends StatefulWidget {
  const Filters({
    Key? key,
    required this.filters,
    required this.onFiltersChange,
  }) : super(key: key);

  final List<String> filters;
  final void Function(List<int> selectedFilters) onFiltersChange;

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  late final List<bool> _activations;

  @override
  void initState() {
    super.initState();
    _activations = List.generate(widget.filters.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.filters.length,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FilterChip(
          selected: _activations[index],
          label: Text(
            widget.filters[index],
          ),
          onSelected: (selected) {
            setState(() {
              _activations[index] = selected;
            });
            widget.onFiltersChange([
              for (int i = 0; i < _activations.length; i++)
                if (_activations[i]) i
            ]);
          },
        ),
      ),
    );
  }
}
