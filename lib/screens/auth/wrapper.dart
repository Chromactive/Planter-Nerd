import 'package:flutter/material.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:provider/provider.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Authentication>(
      builder: (context, auth, child) {
        switch (auth.status) {
          case AuthStatus.authenticating:
          case AuthStatus.unauthenticated:
            return Container();
          case AuthStatus.authenticated:
            return auth.isLoading ? Container() : Container();
          case AuthStatus.uninitialized:
          default:
            return Container();
        }
      },
    );
  }
}
