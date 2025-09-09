import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String username;
  final String email;
  final String imageUrl;
  final DateTime joinedData;
  final DateTime updatedDate;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.joinedData,
    required this.updatedDate,
  });
  //convert to json object
  Map<String, dynamic> toJson() {
    return {
      "userid": userId,
      "username": username,
      "email": email,
      "imageUrl": imageUrl,
      "joinedData": joinedData,
      "updatedDate": updatedDate,
    };
  }

  //reconvert from json object to usermodel object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["userid"],
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      imageUrl: json["imageUrl"] ?? "",
      joinedData:  (json["joinedData"] ?? "" as Timestamp).toDate(),
      updatedDate: (json["updatedDate"] ?? "" as Timestamp).toDate(),
    );
  }
}
