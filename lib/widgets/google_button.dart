import 'package:flutter/material.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _signingIn = false;

  void _signIn() async {
    setState(() {
      _signingIn = true;
    });
    print('Signing In');
    await Future.delayed(Duration(seconds: 1), () => true);
    setState(() {
      _signingIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _signingIn
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          )
        : OutlinedButton(
            onPressed: _signIn,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(theme.colorScheme.onBackground),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Image(
                    image: AssetImage('assets/google_logo.png'),
                    height: 35.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Sign in with Google',
                      style: theme.textTheme.button?.copyWith(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
