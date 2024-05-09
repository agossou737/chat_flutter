import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app/auth/landing_screen.dart';
import 'package:chat_app/auth/login_screen.dart';
import 'package:chat_app/auth/otp_screen.dart';
import 'package:chat_app/auth/user_informations_screen.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/main_screen/main_screen.dart';
import 'package:chat_app/main_screen/profile_screen.dart';
import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  'package:firebase_core/firebase_core.dart';

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthentificationProvider()),
      ],
      child: MyApp(
        savedThemeMode: savedThemeMode,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.deepPurple,
        ),
        dark: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.purple,
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) {
          return MaterialApp(
            title: 'Flutter Chat Pro',
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            initialRoute: Constants.landingScreen,
            routes: {
              Constants.landingScreen: (context) => const LandingScreen(),
              Constants.loginScreen: (context) => const LoginScreen(),
              Constants.profileScreen: (context) => const ProfileScreen(),
              Constants.otpScreen: (context) => const OtpScreen(),
              Constants.userInformationsScreen: (context) =>
                  const UserInformationsScreen(),
              Constants.homeScreen: (context) => const HomeScreen(),
            },
          );
        });
  }
}
