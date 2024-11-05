import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/widgets/app_bar_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthentificationProvider>().userModel!;

    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackBtn.appBarBackBtn(
          () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          currentUser.uid == uid
              ? IconButton(
                  onPressed: () {
                    // create dialog to confirm logout

                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Se déconnecter"),
                              content: const Text(
                                "Etes vous sûr de vouloir partir ?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Retour"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await context
                                        .read<AuthentificationProvider>()
                                        .logout()
                                        .whenComplete(() {
                                      Navigator.of(context).pop();
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Constants.loginScreen,
                                        (route) => false,
                                      );
                                    });
                                  },
                                  child: const Text("Se Déconnecter"),
                                ),
                              ],
                            ));
                  },
                  icon: const Icon(
                    Icons.logout,
                  ),
                )
              : const SizedBox()
        ],
      ),
      body: Center(
        child: Card(
          child: SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? Colors.white : Colors.black),
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
              value: isDarkMode,
              onChanged: (val) {
                setState(() {
                  isDarkMode = val;
                });

                if (val) {
                  AdaptiveTheme.of(context).setDark();
                } else {
                  AdaptiveTheme.of(context).setLight();
                }
              }),
        ),
      ),
    );
  }
}
