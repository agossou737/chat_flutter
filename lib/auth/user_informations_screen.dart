import 'dart:io';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/asset_manager.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/utilities/global.dart';
import 'package:chat_app/widgets/app_bar_back_button.dart';
import 'package:chat_app/widgets/display_user_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class UserInformationsScreen extends StatefulWidget {
  const UserInformationsScreen({super.key});

  @override
  State<UserInformationsScreen> createState() => _UserInformationsScreenState();
}

class _UserInformationsScreenState extends State<UserInformationsScreen> {
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  final TextEditingController nameController = TextEditingController();

  String userImage = "";
  File? finalFileImage;

  @override
  void dispose() {
    btnController.stop();
    nameController.dispose();
    super.dispose();
  }

  void selectImage(
    bool fromCamera,
    context,
  ) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showCustomSnackBar(
          context,
          message,
        );
      },
    );

    if (finalFileImage != null) {
      await cropImage(finalFileImage!.path, context);
      Navigator.pop(context);
    } else {
      showCustomSnackBar(
        context,
        "Aucune image sélectionnée",
      );
    }

    // if (finalFileImage != null) {
    //   setState(
    //     () {
    //       userImage = finalFileImage!.path;
    //     },
    //   );
    // }
  }

  Future<void> cropImage(filePath, context) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      // Navigator.of(context).pop();

      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      } else {
        //  Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackBtn.appBarBackBtn(() {
          Navigator.of(context).pop();
        }),
        centerTitle: true,
        title: const Text('User Informations'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            children: [
              DisplayUserImage.displayUserImage(
                finalFileImage: finalFileImage,
                radius: 60,
                onPressed: () {
                  showBottom();
                },
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Entrez votre nom",
                  labelText: "Votre nom",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: btnController,
                  onPressed: () {
                    // save user informations to firestore
                    saveUserDataToFireStore();
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Theme.of(context).primaryColor,
                  child: const Text(
                    "Continuer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showBottom() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(5),
            height: 150,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      selectImage(true, context);
                      Navigator.of(context).pop();
                    },
                    leading: const Icon(
                      Icons.camera_alt,
                    ),
                    title: const Text(
                      "Caméra",
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      selectImage(false, context);
                      // Navigator.of(context).pop();
                    },
                    leading: const Icon(
                      Icons.image,
                    ),
                    title: const Text(
                      "Gallerie",
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void saveUserDataToFireStore() {
    final AuthentificationProvider authProvider =
        context.read<AuthentificationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid,
      name: nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber,
      image: "",
      token: "",
      createdAt: "",
      lastSeen: "",
      isOnline: true,
      friends: [],
      friendRequestUIDs: [],
      sendFriendsRequestUIDs: [],
      aboutMe: "Hey!  I'm using flutter chat pro",
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      fileImage: finalFileImage,
      onSuccess: () async {
        btnController.success();
        await authProvider.saveUserDataToSharedPreferences();
        // await Future.delayed(const Duration(seconds: 1));
        // btnController.reset();
        navigateToHomeScreen();
      },
      onFailed: () async {
        btnController.error();
        showCustomSnackBar(
          context,
          "Une erreur est survenue lors de l'enregistrement de l'utilisateur.",
        );
        await Future.delayed(const Duration(seconds: 5));
        btnController.reset();
      },
    );
  }

  void navigateToHomeScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }
}
