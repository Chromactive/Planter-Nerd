import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/routes.dart';
import 'package:planter_squared/widgets/form.dart';
import 'package:planter_squared/widgets/text.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  Authentication? _auth;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    await _auth!
        .signIn(email: email, password: password)
        .then((value) => (_auth!.firebaseUser?.emailVerified ?? false)
            ? Navigator.pop(context)
            : Navigator.pushReplacementNamed(context, Routes.verify))
        .catchError((error, _) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    _auth = Provider.of<Authentication>(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
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
              LoginForm(
                emailController: _emailController,
                passwordController: _passwordController,
                submit: (formKey) async {
                  if (formKey.currentState!.validate()) {
                    await _login();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordConfirmController;
  Authentication? _auth;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordConfirmController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future _signup() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String username = _usernameController.text;
    _auth!.nextName = username;
    await _auth!
        .signUp(email: email, username: username, password: password)
        .then((value) => (_auth!.firebaseUser?.emailVerified ?? false)
            ? Navigator.pop(context)
            : Navigator.pushReplacementNamed(context, Routes.verify))
        .catchError((error, _) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    _auth = Provider.of<Authentication>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
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
              SignupForm(
                emailController: _emailController,
                usernameController: _usernameController,
                passwordController: _passwordController,
                passwordConfirmationController: _passwordConfirmController,
                submit: (formKey) async {
                  if (formKey.currentState!.validate()) {
                    await _signup();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.submit,
  }) : super(key: key);

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function(GlobalKey<FormState> formKey) submit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _key,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FormInputText(
              controller: widget.emailController,
              fieldName: 'Email Address',
              textInputType: TextInputType.emailAddress,
              fieldHint: 'example@domain.com',
              required: true,
              showSuggestions: true,
              validators: FormTextFieldValidators.emailField,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: FormInputText(
              controller: widget.passwordController,
              fieldName: 'Password',
              obscureText: true,
              required: true,
              autocorrect: false,
              showSuggestions: false,
              textInputAction: TextInputAction.done,
              validators: FormTextFieldValidators.passwordField,
            ),
          ),
          TextButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12.0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(
              'Forgot password?',
              style: theme.textTheme.labelLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Hero(
              tag: 'login_btn',
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          _isSubmitting = true;
                        });
                        await widget.submit(_key);
                        if (mounted) {
                          setState(() {
                            _isSubmitting = false;
                          });
                        }
                      },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(32.0),
                  primary: theme.colorScheme.onBackground,
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: _isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
                        ),
                      )
                    : Text(
                        'Log in',
                        style: theme.textTheme.button?.copyWith(fontSize: 18, color: theme.colorScheme.onPrimary),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({
    Key? key,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.submit,
  }) : super(key: key);

  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final Future<void> Function(GlobalKey<FormState> formKey) submit;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      autovalidateMode: AutovalidateMode.always,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FormInputText(
              controller: widget.emailController,
              fieldName: 'Email Address',
              fieldHint: 'example@domain.com',
              textInputType: TextInputType.emailAddress,
              validators: FormTextFieldValidators.emailField,
              required: true,
              showSuggestions: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormInputText(
                controller: widget.usernameController,
                fieldName: 'Username',
                fieldHint: WordPair.random().asPascalCase,
                textInputType: TextInputType.name,
                autocorrect: true,
                required: true,
                showSuggestions: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormInputText(
                controller: widget.passwordController,
                fieldName: 'Password',
                obscureText: true,
                required: true,
                validators: FormTextFieldValidators.passwordField,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormInputText(
                controller: widget.passwordConfirmationController,
                fieldName: 'Confirm your password',
                obscureText: true,
                required: true,
                textInputAction: TextInputAction.done,
                validators: [
                  FieldValidator(
                    checker: (value) => widget.passwordController.text == value,
                    message: 'Passwords must match',
                  ),
                ],
              ),
            ),
            Hero(
              tag: 'signup_btn',
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          _isSubmitting = true;
                        });
                        await widget.submit(_key);
                        if (mounted) {
                          setState(() {
                            _isSubmitting = false;
                          });
                        }
                      },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(32),
                  primary: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).focusColor,
                ),
                child: _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
