import 'package:chat_app/utilities/constants.dart';

class UserModel {
  String? uid;
  String? aboutMe;
  String? phoneNumber;
  String? image;
  String? token;
  String? name;
  String? lastSeen;
  String? createdAt;
  bool? isOnline;
  List<String>? friends;
  List<String>? friendRequestUIDs;
  List<String>? sendFriendsRequestUIDs;

  UserModel({
    required this.uid,
    required this.aboutMe,
    required this.phoneNumber,
    required this.image,
    required this.token,
    required this.name,
    required this.lastSeen,
    required this.createdAt,
    required this.isOnline,
    required this.friends,
    required this.friendRequestUIDs,
    required this.sendFriendsRequestUIDs,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[Constants.uid] ?? '',
      aboutMe: map[Constants.aboutMe] ?? '',
      phoneNumber: map[Constants.phoneNumber] ?? '',
      image: map[Constants.image] ?? '',
      token: map[Constants.token] ?? '',
      name: map[Constants.name] ?? '',
      lastSeen: map[Constants.lastSeen] ?? '',
      createdAt: map[Constants.createdAt] ?? '',
      isOnline: map[Constants.isOnline] ?? false,
      friends: List<String>.from(
          map[Constants.fiendsUIDs] ?? []), // Type casting for safety
      friendRequestUIDs: List<String>.from(
          map[Constants.friendRequestsUIDs] ?? []), // Type casting for safety
      sendFriendsRequestUIDs: List<String>.from(
          map[Constants.sendFriendsRequestUIDs] ??
              []), // Type casting for safety
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.aboutMe: aboutMe,
      Constants.phoneNumber: phoneNumber,
      Constants.image: image,
      Constants.token: token,
      Constants.name: name,
      Constants.lastSeen: lastSeen,
      Constants.createdAt: createdAt,
      Constants.isOnline: isOnline,
      Constants.fiendsUIDs: friends,
      Constants.friendRequestsUIDs: friendRequestUIDs,
      Constants.sendFriendsRequestUIDs: sendFriendsRequestUIDs,
    };
  }
}
