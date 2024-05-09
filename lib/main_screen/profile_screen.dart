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
                      // authentificationProvider.logout();
                    },
                    icon: const Icon(Icons.logout),
                  )
                : const SizedBox()
          ]),
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
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                buildFriendsRequestBtn(
                    currentUser: currentUser!, userModel: userModel)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildFriendsRequestBtn({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid) {
      if (userModel.friendRequestUIDs!
          .isNotEmpty /* currentUser.friendRequestUIDs!.contains(userModel.uid) */) {
        return ElevatedButton(
          onPressed: () {
            // Navigate to friends request screen
            
          },
          child: Text(
            "Voir l'invitation".toUpperCase(),
            style: GoogleFonts.openSans(
              textStyle: const TextStyle(
                fontSize: 12,
                //   color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }
}
