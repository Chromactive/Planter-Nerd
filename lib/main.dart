import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planter_squared/firebase_options.dart';
import 'package:planter_squared/screens/login_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PlanterSquared());
}

class PlanterSquared extends StatelessWidget {
  const PlanterSquared({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planter Squared',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
