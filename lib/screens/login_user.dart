import 'package:flutter/material.dart';
import 'package:planter_squared/res/auth_exceptions.dart';
import 'package:planter_squared/res/auth_repo.dart';
import 'package:planter_squared/utils/form_field_validators.dart';
import 'package:planter_squared/utils/routes.dart';
import 'package:planter_squared/widgets/form_input.dart';
import 'package:planter_squared/widgets/google_button.dart';
import 'package:planter_squared/widgets/text_widgets.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  Future<void> _loginUser(Auth auth) async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    await auth
        .loginUser(email: email, password: password)
        .onError<AuthException>(
            (error, _) => showSnackbar(error.message, context));
  }

  void _navigateToSignup() {
    Navigator.of(context).pushNamed(Routers.signup);
  }

  @override
  Widget build(BuildContext context) {
    final Auth authService = Provider.of(context);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
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
                  LoginForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    submit: (formKey) async {
                      if (formKey.currentState!.validate()) {
                        await _loginUser(authService);
                      }
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text('Don\'t have an account?'),
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToSignup,
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
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        _isSubmitting = true;
                      });
                      await widget.submit(_key);
                      setState(() {
                        _isSubmitting = false;
                      });
                    },
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(32.0),
                primary: theme.colorScheme.onBackground,
                backgroundColor: theme.colorScheme.primary,
              ),
              child: _isSubmitting
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
                      ),
                    )
                  : Text(
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
