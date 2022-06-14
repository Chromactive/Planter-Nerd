import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/models/model_fields.dart';
import 'package:planter_squared/data/models/todo.dart';
import 'package:planter_squared/data/util/constants.dart';
import 'package:planter_squared/data/util/firebase_service.dart';

class AuthUser {
  const AuthUser({
    this.uid,
    this.name,
    this.email,
    required this.planterDatabase,
    required this.taskDatabase,
  });

  final String? uid;
  final String? name;
  final String? email;
  final DatabaseService<Planter> planterDatabase;
  final DatabaseService<Task> taskDatabase;

  AuthUser.load(Json data)
      : uid = data[UserFields.uid],
        name = data[UserFields.name],
        email = data[UserFields.email],
        planterDatabase = CloudDatabaseService(
          collection:
              '${DatabaseConstants.userCollection}/${data[UserFields.uid]}/${DatabaseConstants.planterCollection}',
          fromJson: Planter.load,
          toJson: (planter) => planter.json(),
        ),
        taskDatabase = CloudDatabaseService(
          collection: '${DatabaseConstants.userCollection}/${data[UserFields.uid]}/${DatabaseConstants.taskCollection}',
          fromJson: Task.load,
          toJson: (task) => task.json(),
        );

  Json json() => {
        UserFields.uid: uid,
        UserFields.name: name,
        UserFields.email: email,
      };
}
