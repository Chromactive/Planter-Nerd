import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routers {
  const Routers._();
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
}

void showSnackbar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}
