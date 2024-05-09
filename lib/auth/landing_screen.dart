import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/asset_manager.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAuthentification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400.0,
          width: 200,
          child: Column(
            children: [
              Lottie.asset(
                AssetManager.chatBubble,
              ),
              const LinearProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }

  void checkAuthentification() async {
    final AuthentificationProvider authentificationProvider =
        context.read<AuthentificationProvider>();
    bool isAuth = await authentificationProvider.checkAuthentificationState();

    navigate(isAuth: isAuth);
  }

  void navigate({required bool isAuth}) {
    if (isAuth) {
      Navigator.pushReplacementNamed(
        context,
        Constants.homeScreen,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        Constants.loginScreen,
      );
    }
  }
}
