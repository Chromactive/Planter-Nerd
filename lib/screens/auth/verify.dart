import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/widgets/text.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final Authentication _auth;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _auth = Provider.of<Authentication>(context, listen: false);
    _sendEmail();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  Future _checkEmailVerified() async {
    if ((_auth.firebaseUser?.emailVerified ?? false)) {
      _timer?.cancel();
      Navigator.pop(context);
    }
  }

  Future _signOut() async {
    await _auth.signOut();
    Navigator.pop(context);
  }

  Future _sendEmail() async {
    try {
      await _auth.sendVerificationEmail();
    } on Exception catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async {
        await _auth.signOut();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Superscript(
                  base: const Text('Email verification'),
                  superscript: const Text('sent'),
                  baseStyle: textTheme.headlineSmall,
                  superscriptStyle: textTheme.headlineSmall,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Please confirm a verification email has been sent to your address.'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: _sendEmail,
                      style:
                          TextButton.styleFrom(primary: colorScheme.onBackground, backgroundColor: colorScheme.primary),
                      child: const Text('Send verification email'),
                    ),
                    TextButton(
                      onPressed: _signOut,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
