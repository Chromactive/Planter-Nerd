import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planter_squared/firebase_options.dart';
import 'package:planter_squared/model/auth_user.dart';
import 'package:planter_squared/res/auth_repo.dart';
import 'package:planter_squared/screens/login_user.dart';
import 'package:planter_squared/screens/signup_user.dart';
import 'package:planter_squared/utils/routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PlanterSquared());
}

class PlanterSquared extends StatelessWidget {
  const PlanterSquared({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
      ],
      child: MaterialApp(
        title: 'Planter Squared',
        debugShowCheckedModeBanner: false,
        initialRoute: Routers.home,
        routes: {
          Routers.home: (context) => const UserAuthWrapper(),
          Routers.login: (context) => const LoginPage(),
          Routers.signup: (context) => const SignupPage(),
        },
      ),
    );
  }
}

class UserAuthWrapper extends StatelessWidget {
  const UserAuthWrapper({Key? key}) : super(key: key);

  Widget _dataStreamProcessing() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _dataStreamProcessed(AsyncSnapshot<AuthUser?> snapshot, Auth auth) {
    if (snapshot.hasData) {
      // TODO: obviously change this
      return Center(
        child: Column(
          children: [
            Text('${auth.user.username}'),
            TextButton(
              child: Text('Logout'),
              onPressed: auth.signOut,
            ),
          ],
        ),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text('${snapshot.error}'),
      );
    } else {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Auth authService = Provider.of(context);
    return StreamBuilder<AuthUser?>(
      stream: authService.onAuthStateChanges,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return _dataStreamProcessing();
          case ConnectionState.done:
          case ConnectionState.active:
            return _dataStreamProcessed(snapshot, authService);
        }
      },
    );
  }
}
