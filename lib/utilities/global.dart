import 'dart:io';

import 'package:chat_app/utilities/asset_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(
        seconds: 3,
      ),
    ),
  );
}

Widget userImageWidget({
  required String userImage,
  required double radius,
  required Function()? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      backgroundColor: Colors.white,
      radius: radius,
      backgroundImage: userImage.isNotEmpty
          ? NetworkImage(userImage)
          : const AssetImage(AssetManager.user) as ImageProvider,
    ),
  );
}

Future<File?> pickImage({
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;

  if (fromCamera) {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        onFail("Aucune image sélectionnée");
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      debugPrint(e.toString());
      onFail("Une erreur est survenue :: $e");
    }
  } else {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFail("Aucune image sélectionnée");
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      debugPrint(e.toString());
      onFail("Une erreur est survenue :: $e");
    }
  }

  return fileImage;
}

Future<File?> pickImageGemini(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    return File(pickedFile.path);
  } else {
    return null;
  }
}
