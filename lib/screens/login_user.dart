import 'package:flutter/material.dart';
import 'package:planter_squared/utils/form_field_validators.dart';
import 'package:planter_squared/utils/keyboard_adjustable.dart';
import 'package:planter_squared/utils/text_with_dividers.dart';
import 'package:planter_squared/widgets/form_input.dart';
import 'package:planter_squared/widgets/google_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: KeyboardAdjustable(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GoogleSignInButton(),
                  ),
                  const DividerText(
                    centerChild: Text(
                      'Or',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const LoginForm(),
                  const Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text('Don\'t have an account?'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(32),
                      primary: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).focusColor,
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FormInputText(
              controller: _emailController,
              fieldName: 'Email Address',
              textInputType: TextInputType.emailAddress,
              fieldHint: 'example@domain.com',
              required: true,
              validators: FormTextFieldValidators.emailField,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: FormInputText(
              controller: _passwordController,
              fieldName: 'Password',
              obscureText: true,
              required: true,
              textInputAction: TextInputAction.done,
              validators: FormTextFieldValidators.passwordField,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(
              'Forgot password?',
              style: theme.textTheme.labelLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print('Valid data!');
                }
              },
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(32.0),
                primary: theme.colorScheme.onBackground,
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                'Log in',
                style: theme.textTheme.button?.copyWith(
                    fontSize: 18, color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
