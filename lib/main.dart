import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';
import 'package:just_busses/helpers/authentication_service.dart';
import 'package:just_busses/helpers/database_methods.dart';
import 'package:just_busses/theme/app_colors.dart';
import 'package:just_busses/views/driver/screen1.dart';
import 'package:just_busses/views/moderator/moderator_home.dart';
import 'package:just_busses/views/student/student_home.dart';
import 'package:just_busses/views/student/sign_up.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp();
  GoogleMap.init(FlutterConfig.get('GOOGLE_API_KEY'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
        )
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(),
          title: 'Flutter Demo',
          theme: ThemeData(
            primaryColor: AppColors.aquaBlue,
            accentColor: AppColors.yellow,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: AuthenticationWrapper()),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if (firebaseUser != null) {
      String email = firebaseUser.email;
      DatabaseMethods.getUserRole(email).then((role) => () {
            if (role == "s")
              return StudentHome(); //return home if user is logged in
            else if (role == "m")
              return ModeratorHome();
            else if (role == "d") return Screen1();
          });
    }
    return SignUp();
    // SignUp();
  }
}
