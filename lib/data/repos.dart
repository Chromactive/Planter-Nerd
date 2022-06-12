import 'package:planter_squared/data/models/user.dart';
import 'package:planter_squared/data/util/constants.dart';
import 'package:planter_squared/data/util/firebase_service.dart';

DatabaseService<AuthUser> userDatabase = CloudDatabaseService(
    collection: DatabaseConstants.userCollection, fromJson: AuthUser.load, toJson: (user) => user.json());
