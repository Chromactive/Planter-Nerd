import 'package:flutter/material.dart';

class DividerText extends StatelessWidget {
  const DividerText({
    Key? key,
    required this.centerChild,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
  }) : super(key: key);

  final Widget centerChild;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Colors.black,
          ),
        ),
        Padding(
          padding: padding,
          child: centerChild,
        ),
        const Expanded(
          child: Divider(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class Superscript extends StatelessWidget {
  const Superscript({
    Key? key,
    required this.base,
    required this.superscript,
    this.style,
  }) : super(key: key);

  final Widget base;
  final String superscript;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    Widget child = Text(superscript, style: style);
    if (base is! Text) {
      child = Transform.translate(
          offset: Offset(0, -((style?.fontSize ?? 14)) * .5), child: child);
    }

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          WidgetSpan(
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.merge(style),
              child: base,
            ),
          ),
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            alignment: PlaceholderAlignment.bottom,
            child: child,
          ),
        ],
      ),
      style: style,
    );
  }
}
