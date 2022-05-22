class AuthExceptions {
  const AuthExceptions._();
  static const AuthExceptions instance = AuthExceptions._();

  static const String messageEmailUsed =
      'An account with that email address already exists';
  static const String messageInvalidEmail = 'Invalid email address';
  static const String messageWeakPassword = 'Password is weak';
  static const String messageWrongPassword = 'Password is wrong';
  static const String messageUserNotFound =
      'No user with that email address was found';
  static const String messageRequestFailed = 'Request failed. Try again later';

  AuthException operator [](String code) {
    String message;
    switch (code) {
      case 'email-already-in-use':
        message = messageEmailUsed;
        break;
      case 'invalid-email':
        message = messageInvalidEmail;
        break;
      case 'weak-password':
        message = messageWeakPassword;
        break;
      case 'user-not-found':
        message = messageUserNotFound;
        break;
      case 'wrong-password':
        message = messageWrongPassword;
        break;
      case 'network-request-failed':
        message = messageRequestFailed;
        break;
      default:
        message = 'Unknown Error';
        break;
    }
    return AuthException(message: message);
  }
}

class AuthException implements Exception {
  const AuthException({required this.message});

  final String message;
}
