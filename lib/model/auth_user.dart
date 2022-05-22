import 'package:planter_squared/model/json_model_params.dart';
import 'package:planter_squared/res/auth_repo.dart';

class AuthUser {
  const AuthUser({
    required this.uid,
    required this.emailAddress,
    required this.username,
  });

  final String uid;
  final String emailAddress;
  final String username;

  Json toJson() => {
        AuthUserParams.uid: uid,
        AuthUserParams.emailAddress: emailAddress,
        AuthUserParams.username: username,
      };

  static AuthUser load(Json json) => AuthUser(
      uid: json[AuthUserParams.uid],
      emailAddress: json[AuthUserParams.emailAddress],
      username: json[AuthUserParams.username]);
}
