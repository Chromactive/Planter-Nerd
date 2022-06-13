import 'package:flutter/material.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/routes.dart';
import 'package:planter_squared/widgets/text.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final Authentication auth = Provider.of(context, listen: false);
    if (auth.status == AuthStatus.authenticating && !(auth.firebaseUser?.emailVerified ?? false)) {
      Navigator.pushNamed(context, Routes.verify);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'greeting',
              child: Superscript(
                base: const Text('Welcome to Planter'),
                superscript: const Text('Squared'),
                baseStyle: textTheme.headlineSmall,
                superscriptStyle: textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Spacer(),
                  Expanded(
                    flex: 8,
                    child: AuthButtons(),
                  ),
                  Spacer(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AuthButtons extends StatelessWidget {
  const AuthButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Column(
      children: [
        Hero(
          tag: 'login_btn',
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.login);
            },
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(32),
              primary: colorScheme.onBackground,
              backgroundColor: colorScheme.primary,
            ),
            child: Text(
              'LOGIN',
              style: textTheme.titleLarge,
            ),
          ),
        ),
        Hero(
          tag: 'signup_btn',
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.signup);
            },
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(32),
              primary: colorScheme.primary,
              backgroundColor: theme.focusColor,
            ),
            child: Text(
              'SIGN UP',
              style: textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
  }
}
