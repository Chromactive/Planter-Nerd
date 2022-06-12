import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planter_squared/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PlanterNerd());
}

class PlanterNerd extends StatelessWidget {
  const PlanterNerd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planter Nerd',
      debugShowCheckedModeBanner: false,
      home: Container(),
    );
  }
}
