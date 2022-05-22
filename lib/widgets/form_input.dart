import 'package:flutter/material.dart';

class FormInputText extends StatefulWidget {
  const FormInputText({
    Key? key,
    required this.controller,
    required this.fieldName,
    this.validators = const [],
    this.textInputType = TextInputType.text,
    this.fieldHint = '',
    this.required = false,
    this.obscureText = false,
    this.autocorrect = false,
    this.showSuggestions = false,
    this.textInputAction = TextInputAction.next,
  }) : super(key: key);

  final TextEditingController controller;
  final String fieldName;
  final String fieldHint;
  final bool obscureText;
  final bool required;
  final bool autocorrect;
  final bool showSuggestions;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final List<FieldValidator> validators;

  @override
  State<FormInputText> createState() => _FormInputTextState();
}

class _FormInputTextState extends State<FormInputText> {
  late bool _isShowingField;

  @override
  void initState() {
    super.initState();
    _isShowingField = !widget.obscureText;
  }

  void _toggleFieldVisibility() {
    if (widget.obscureText) {
      setState(() {
        _isShowingField = !_isShowingField;
      });
    }
  }

  String? _validator(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return 'Required';
    }
    for (final validator in widget.validators) {
      if (!validator.checker(value)) {
        return validator.message;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInputType,
      textInputAction: widget.textInputAction,
      obscureText: !_isShowingField,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.showSuggestions,
      validator: _validator,
      decoration: InputDecoration(
          labelText: widget
              .fieldName, //(widget.required ? '* ' : '') + widget.fieldName,
          hintText: widget.fieldHint,
          border: OutlineInputBorder(
            borderSide:
                Divider.createBorderSide(context, color: theme.dividerColor),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  splashRadius: Material.defaultSplashRadius * 0.5,
                  onPressed: _toggleFieldVisibility,
                  icon: Icon(_isShowingField
                      ? Icons.visibility
                      : Icons.visibility_off),
                )
              : null),
    );
  }
}

class FieldValidator {
  const FieldValidator({
    required this.checker,
    required this.message,
  });

  final bool Function(String?) checker;
  final String message;
}
