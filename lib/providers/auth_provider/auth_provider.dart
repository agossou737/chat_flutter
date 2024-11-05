import 'dart:convert';
import 'dart:io';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/utilities/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthentificationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;

  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessFul => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Check Authentification state

  Future<bool> checkAuthentificationState() async {
    bool isSignedIn = false;

    await Future.delayed(const Duration(seconds: 2));

    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;

      await getUserDataFromFireStore();

      await saveUserDataToSharedPreferences();

      notifyListeners();
      isSignedIn = true;
    } else {
      isSignedIn = false;
    }
    return isSignedIn;
    // _isLoading = true; Ceci est un code que j'ai voulu conservé
    // if (_auth.currentUser != null) {
    //   _uid = _auth.currentUser!.uid;
    //   _phoneNumber = _auth.currentUser!.phoneNumber;
    //   _isSuccessful = true;
    //   _isLoading = false;
    //   notifyListeners();

    //   Navigator.of(context).pushReplacementNamed(Constants.homeScreen);
    // } else {
    //   _isLoading = false;
    //   notifyListeners();
    // }
  }
  // check if user exists in database

  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }

    // final result = await _firestore
    //     .collection(Constants.users)
    //     .where(Constants.phoneNumber, isEqualTo: phoneNumber)
    //     .get();

    // return result.docs.isNotEmpty;
  }

  // get user data from firestore

  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();

    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }
  // save user data to shared preferences

  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
      Constants.userModel,
      jsonEncode(
        userModel!.toMap(),
      ),
    );
  }

  // get user data from shared preferences

  Future<void> getUsersDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelJson =
        sharedPreferences.getString(Constants.userModel) ?? "";
    _userModel = UserModel.fromMap(jsonDecode(userModelJson));
    _uid = _userModel!.uid;
    _phoneNumber = _userModel!.phoneNumber;
    notifyListeners();
  }

  // Sign in with phone number

  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext ctx,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then(
            (value) async {
              _uid = value.user!.uid;
              _phoneNumber = value.user!.phoneNumber;
              _isSuccessful = true;
              _isLoading = false;

              notifyListeners();
            },
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();

          showCustomSnackBar(ctx, e.message!);
        },
        codeSent: (String verification, int? resendToken) async {
          _isLoading = false;
          notifyListeners();
          showCustomSnackBar(ctx, "Code Envoyé");
          //Navigate to OTP screen

          Navigator.of(ctx).pushNamed(Constants.otpScreen, arguments: {
            Constants.verificationId: verification,
            Constants.phoneNumber: phoneNumber,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  //verify otp code
  Future<void> verifyOtpCode({
    required String verificationId,
    required String otpCode,
    required BuildContext ctx,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }).catchError(
      (e) {
        _isSuccessful = true;
        _isLoading = false;
        notifyListeners();

        showCustomSnackBar(ctx, e.toString());
      },
    );
  }

  //save user data to firestore

  Future<void> saveUserDataToFireStore({
    required UserModel? userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function onFailed,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (fileImage != null) {
        // upload image to storage
        // String fileName = _uid!;
        // // Reference reference =
        // //     _storage.ref().child(Constants.users).child(fileName);
        // // UploadTask uploadTask = reference.putFile(fileImage);
        // // TaskSnapshot taskSnapshot = await uploadTask;
        // // String imageUrl = await taskSnapshot.ref.getDownloadURL();

        String? imageUrl = await storeImageToStorage(
          file: fileImage,
          reference: "${Constants.userImages}/${userModel!.uid}",
        );
        userModel.image = imageUrl;
      }

      userModel!.lastSeen = DateTime.now().millisecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      await _firestore.collection(Constants.users).doc(userModel.uid).set(
            userModel.toMap(),
            SetOptions(
              merge: true,
            ),
          );

      _isLoading = false;
      // _isSuccessful = true;
      onSuccess();

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onFailed(e.toString());
    }
  }

  //store image to storage and return image url

  Future<String?> storeImageToStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  // get user stream

  Stream<DocumentSnapshot> userStream({required String userID}) {
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }

  // get all users stream
  Stream<QuerySnapshot> getAllUserStreams(String userID) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userID)
        .snapshots();
  }

  // send friend request
  Future<void> sendFriendRequest({required String friendID}) async {
    try {
      // add our uid to friend request
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });

      // add friend uid to our friend request sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sendFriendsRequestUIDs: FieldValue.arrayUnion([friendID]),
      });
    } catch (e) {
      debugPrint("exception : $e");
    }
  }

  // cancel friend request
  Future<void> cancelFriendRequest({required String friendID}) async {
    try {
      // remove our uid from friend request
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });

      // remove friend uid from our friend request sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sendFriendsRequestUIDs: FieldValue.arrayRemove([friendID]),
      });
    } catch (e) {
      debugPrint("exception : $e");
    }
  }

  // logout

  Future<void> logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }

  /*
 Ceci est code que j'ai voulu conservé ça ne fait aucune action 
  Stream<UserModel?> get userStream {
    return _firestore.collection(Constants.users).doc(_uid).snapshots().map(
      (snapshot) {
        if (snapshot.data() != null) {
          return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
        } else {
          return null;
        }
      },
    );
  } */
}
