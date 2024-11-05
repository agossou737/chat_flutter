import 'package:chat_app/main_screen/settings_screen.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/utilities/global.dart';
import 'package:chat_app/widgets/app_bar_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final AuthentificationProvider authentificationProvider =
        context.read<AuthentificationProvider>();
    // get user data from arguments
    final String uid = ModalRoute.of(context)!.settings.arguments as String;
    final currentUser = context.read<AuthentificationProvider>().userModel;
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
          authentificationProvider.uid == uid
              ? IconButton(
                  onPressed: () {
                    // navigate to settings page
                    Navigator.pushNamed(
                      context,
                      Constants.settingScreen,
                      arguments: uid,
                    );
                  },
                  icon: const Icon(Icons.settings),
                )
              : const SizedBox()
        ],
      ),
      body: StreamBuilder(
        stream: authentificationProvider.userStream(
          userID: uid,
        ),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading"));
          }

          final userModel = UserModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15,
            ),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                    userImage: userModel.image!,
                    radius: 50,
                    onTap: () {},
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(.2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userModel.name!,
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        userModel.phoneNumber!,
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 40,
                            width: 40,
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Mon Profil',
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const SizedBox(
                            height: 40,
                            width: 40,
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        userModel.aboutMe!,
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                buildFriendsRequestBtn(
                  currentUser: currentUser!,
                  userModel: userModel,
                ),
                const SizedBox(
                  height: 10,
                ),
                buildFriendsButton(
                  currentUser: currentUser,
                  userModel: userModel,
                ),
                const SizedBox(
                  height: 10,
                ),
                // buidlSendFriendRequestButton(
                //   currentUser: currentUser,
                //   userModel: userModel,
                // )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildButton({
    required String buttonText,
    required VoidCallback onPressed,
    bool shouldShowButton = true,
  }) {
    if (!shouldShowButton) {
      return const SizedBox();
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          buttonText.toUpperCase(),
          style: GoogleFonts.openSans(
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFriendsRequestBtn({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    bool showButton = currentUser.uid == userModel.uid &&
        userModel.friendRequestUIDs!.isNotEmpty;

    return buildButton(
      buttonText: "Voir l'invitation",
      onPressed: () {
        // Navigate to friends request screen
      },
      shouldShowButton: showButton,
    );
  }

  Widget buildFriendsButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    // Vérification si l'utilisateur est le même et s'il y a des demandes d'amis
    if (currentUser.uid == userModel.uid &&
        userModel.friendRequestUIDs!.isNotEmpty) {
      // Si les conditions sont remplies, afficher le bouton "Voir les amis"
      return buildButton(
        buttonText: "Voir les amis",
        onPressed: () {
          // Action à effectuer pour voir les amis
        },
        shouldShowButton: true, // Le bouton est montré
      );
    } else if (currentUser.uid != userModel.uid) {
      // show cancel friend request if the user sent us a friend request
      String label = "";
      if (userModel.friendRequestUIDs!.contains(currentUser.uid)) {
        label = "Annuler la demande";
        return buildButton(
          buttonText: label,
          onPressed: () async {
            // annuler une demande d'ami à l'utilisateur
            await context
                .read<AuthentificationProvider>()
                .cancelFriendRequest(
                  friendID: userModel.uid!,
                )
                .whenComplete(() {
              showCustomSnackBar(
                context,
                "Demande d'ami annulée",
              );
            });
          },
          shouldShowButton: true, // Le bouton est montré
        );
      } else {
        label = "Envoyer demande d'ami";
        // Si l'utilisateur actuel n'est pas celui de `userModel`, afficher le bouton "Envoyer une demande"
        return buildButton(
          buttonText: label,
          onPressed: () async {
            // Envoyer une demande d'ami à l'utilisateur
            await context
                .read<AuthentificationProvider>()
                .sendFriendRequest(
                  friendID: userModel.uid!,
                )
                .whenComplete(() {
              showCustomSnackBar(
                context,
                "Demande d'ami envoyée",
              );
            });
          },
          shouldShowButton: true, // Le bouton est montré
        );
      }
    } else {
      // Si aucune des conditions n'est remplie, retourner un SizedBox vide
      return const SizedBox.shrink();
    }
  }
}
