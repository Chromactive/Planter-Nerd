import 'package:planter_squared/data/models/model_fields.dart';
import 'package:planter_squared/data/util/firebase_service.dart';

class AuthUser {
  const AuthUser({
    this.uid,
    this.name,
    this.email,
  });

  final String? uid;
  final String? name;
  final String? email;

  AuthUser.load(Json data)
      : uid = data[UserFields.uid],
        name = data[UserFields.name],
        email = data[UserFields.email];

  Json json() => {
        UserFields.uid: uid,
        UserFields.name: name,
        UserFields.email: email,
      };
}
