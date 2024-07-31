import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String nickname;
  final List<String> friends;

  User({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.friends,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'friends': friends,
    };
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc['uid'],
      email: doc['email'],
      nickname: doc['nickname'],
      friends: List<String>.from(doc['friends']),
    );
  }
}
