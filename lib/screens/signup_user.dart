import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:planter_squared/utils/form_field_validators.dart';
import 'package:planter_squared/widgets/form_input.dart';
import 'package:planter_squared/widgets/keyboard_adjustable.dart';
import 'package:planter_squared/widgets/text_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordConfirmationController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmationController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordConfirmationController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: KeyboardAdjustable(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Superscript(
                    base: const Text('Become a Plant'),
                    superscript: 'Nerd',
                    style: textTheme.headline5?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 50.0),
                    child: Text(
                      'Create an account to start keeping your plants alive',
                      style: textTheme.bodyText1?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SignupForm(
                    emailController: _emailController,
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    passwordConfirmationController:
                        _passwordConfirmationController,
                    submit: (formKey) async {
                      if (formKey.currentState!.validate()) {
                        print('Sign up user!');
                        Navigator.of(context).pop();
                      }
                    },
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
            TextButton(
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
          ],
        ),
      ),
    );
  }
}
