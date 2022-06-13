import 'package:flutter/material.dart';

class Superscript extends StatelessWidget {
  const Superscript({
    Key? key,
    required this.base,
    required this.superscript,
    this.baseStyle,
    this.superscriptStyle,
    this.color,
  }) : super(key: key);

  final Widget base;
  final Widget superscript;
  final TextStyle? baseStyle;
  final TextStyle? superscriptStyle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget child = superscript;
    child = Transform.translate(offset: Offset(0, -((baseStyle?.fontSize ?? 30)) * .3), child: child);

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          WidgetSpan(
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.merge(baseStyle).apply(color: color),
              child: base,
            ),
          ),
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            alignment: PlaceholderAlignment.aboveBaseline,
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.merge(superscriptStyle).apply(color: color),
              child: child,
            ),
          ),
        ],
      ),
      style: baseStyle,
    );
  }
}
