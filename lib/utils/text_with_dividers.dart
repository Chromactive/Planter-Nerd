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
