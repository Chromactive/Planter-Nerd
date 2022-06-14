import 'package:flutter/material.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:provider/provider.dart';

const kNoImageDefault = 'https://thepracticalplanter.com/wp-content/uploads/2019/06/Plant-in-Sunlight.jpg';

Widget loadingScreen() {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

PreferredSizeWidget appBar(BuildContext context, {bool goBack = false}) {
  return AppBar(
    leading: goBack
        ? IconButton(
            splashRadius: 24.0,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        : null,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 18.0, top: 12.0, bottom: 4.0),
        child: InkResponse(
          onTap: () {
            Provider.of<Authentication>(context, listen: false).signOut();
          },
          radius: 24.0,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Theme.of(context).appBarTheme.iconTheme!.color!),
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: const Icon(Icons.person),
            ),
          ),
        ),
      ),
    ],
  );
}

class SemiCircularImage extends StatelessWidget {
  const SemiCircularImage({
    Key? key,
    required this.borderRadius,
    this.imageLink,
    this.child,
    this.color,
    this.linearGradient,
  })  : assert(imageLink != null || child != null),
        super(key: key);

  final BorderRadius borderRadius;
  final String? imageLink;
  final LinearGradient? linearGradient;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget? post = child;
    if (linearGradient != null) {
      post = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: linearGradient,
        ),
        child: child,
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color,
        image: imageLink != null
            ? DecorationImage(
                image: NetworkImage(imageLink!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: post,
    );
  }
}

class Range {
  const Range({
    required double minValue,
    required double maxValue,
  })  : _minValue = minValue,
        _maxValue = maxValue,
        assert(minValue <= maxValue);

  final double _minValue;
  final double _maxValue;

  double get min => _minValue;
  double get max => _maxValue;
  bool get isSingleValue => _minValue == _maxValue;

  bool contains(double value) {
    return _minValue <= value && value <= _maxValue;
  }

  double convertToRelative(double value) {
    if (isSingleValue) {
      return value == min
          ? 0.5
          : value < min
              ? 0
              : 1;
    }
    return (value - min) / (max - min);
  }
}

class ExpandedSection extends StatefulWidget {
  const ExpandedSection({
    this.expand = false,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final bool expand;

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection> with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(axisAlignment: 1.0, sizeFactor: animation, child: widget.child);
  }
}
