import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/firebase_options.dart';
import 'package:planter_squared/routes.dart';
import 'package:planter_squared/screens/auth/wrapper.dart';
import 'package:provider/provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authentication.instance()),
      ],
      child: MaterialApp(
        title: 'Planter Nerd',
        debugShowCheckedModeBanner: false,
        routes: {
          Routes.loading: (_) => const AuthenticationWrapper(),
        },
      ),
    );
  }
}
