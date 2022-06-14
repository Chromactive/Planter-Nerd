import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/firebase_options.dart';
import 'package:planter_squared/routes.dart';
import 'package:planter_squared/screens/auth/auth_screens.dart';
import 'package:planter_squared/screens/auth/splash.dart';
import 'package:planter_squared/screens/auth/verify.dart';
import 'package:planter_squared/screens/auth/wrapper.dart';
import 'package:planter_squared/screens/home.dart';
import 'package:planter_squared/screens/plant_details.dart';
import 'package:planter_squared/screens/plant_list.dart';
import 'package:planter_squared/screens/planter_details.dart';
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
            ),
          ),
        ),
        routes: {
          Routes.loading: (_) => const AuthenticationWrapper(),
          Routes.splash: (_) => const SplashScreen(),
          Routes.login: (_) => const LoginScreen(),
          Routes.signup: (_) => const SignupScreen(),
          Routes.verify: (_) => const VerifyEmailScreen(),
          Routes.home: (_) => const HomeScreen(),
          Routes.plantDetails: (_) => const PlantDetailScreen(),
          Routes.plantList: (_) => const PlantListScreen(),
          Routes.planterDetails: (_) => const PlanterDetailScreen(),
        },
      ),
    );
  }
}
