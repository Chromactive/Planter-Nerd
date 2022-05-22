import 'package:flutter/material.dart';

class KeyboardAdjustable extends StatelessWidget {
  const KeyboardAdjustable({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: IntrinsicHeight(child: child),
    );
  }
}
