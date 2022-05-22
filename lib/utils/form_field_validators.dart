import 'package:email_validator/email_validator.dart';
import 'package:planter_squared/widgets/form_input.dart';

class FormTextFieldValidators {
  FormTextFieldValidators._();

  static final emailField = [
    FieldValidator(
      checker: (value) => EmailValidator.validate(value!),
      message: 'Please enter a valid email address',
    ),
  ];

  static final passwordField = [
    FieldValidator(
      checker: (value) => RegExp(r"^.{8,}$").hasMatch(value!),
      message: 'Password must be at least 8 characters long',
    ),
    /*FieldValidator(
      checker: (value) => RegExp(r"(?:.*[A-Z])").hasMatch(value!),
      message: 'Password must contain at least one uppercase letter',
    ),
    FieldValidator(
      checker: (value) => RegExp(r"(?:.*[a-z])").hasMatch(value!),
      message: 'Password must contain at least one lowercase letter',
    ),
    FieldValidator(
      checker: (value) => RegExp(r"(?:.*?[0-9])").hasMatch(value!),
      message: 'Password must contain at least one digit',
    ),
    FieldValidator(
      checker: (value) => RegExp(r"(?:.*?[!@#\$&*~])").hasMatch(value!),
      message: 'Password must contain at least one special character',
    ),*/
  ];
}
