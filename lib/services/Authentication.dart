import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_buy_list/model/User.dart' as modelUser;
import 'package:to_buy_list/model/User.dart';
import 'package:to_buy_list/services/UserProvider.dart';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<String> signupUser({
    required String email,
    required String password,
    required String nickname,
    required BuildContext context,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && nickname.isNotEmpty) {
        auth.UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        modelUser.User user = modelUser.User(
          uid: cred.user!.uid,
          email: email,
          nickname: nickname,
          friends: [],
        );

        await _firestore.collection("users").doc(user.uid).set(user.toMap());

        Provider.of<UserProvider>(context, listen: false).setUser(user);
        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        auth.UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        DocumentSnapshot doc =
            await _firestore.collection("users").doc(cred.user!.uid).get();

        if (doc.exists) {
          modelUser.User user = modelUser.User.fromDocument(doc);
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          res = "success";
        } else {
          res = "User does not exist in Firestore";
        }
      } else {
        res = "Email and password cannot be empty";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<modelUser.User?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(uid).get();
      if (doc.exists) {
        return modelUser.User.fromDocument(doc);
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  Future<modelUser.User?> searchUser({required String nameOrEmail}) async {
    try {
      QuerySnapshot nicknameSnapshot = await _firestore
          .collection("users")
          .where("nickname", isEqualTo: nameOrEmail)
          .get();

      if (nicknameSnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = nicknameSnapshot.docs.first;
        return modelUser.User.fromDocument(doc);
      }
      QuerySnapshot emailSnapshot = await _firestore
          .collection("users")
          .where("email", isEqualTo: nameOrEmail)
          .get();

      if (emailSnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = emailSnapshot.docs.first;
        return modelUser.User.fromDocument(doc);
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  Future<List<User>> getFriendsList({required String userId}) async {
    List<User> friendsList = [];
    try {
      final db = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot =
          await db.collection("users").where("uid", isEqualTo: userId).get();

      for (var doc in querySnapshot.docs) {
        List<dynamic> friends = doc.data().toString().contains("friends")
            ? (doc.data() as Map<String, dynamic>)["friends"]
            : [];

        for (var friendId in friends) {
          DocumentSnapshot friendDoc =
              await db.collection("users").doc(friendId.toString()).get();
          if (friendDoc.exists) {
            friendsList.add(User.fromDocument(friendDoc));
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return friendsList;
  }

  Future<bool> ktraban(
      {required String userId, required String friendId}) async {
    try {
      final db = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await db
          .collection("users")
          .where("uid", isEqualTo: userId)
          .where("friends", arrayContains: friendId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<void> addFriend(
      {required String userId, required String friendId}) async {
    try {
      DocumentReference userRef = _firestore.collection("users").doc(userId);
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        List<String> friends = List<String>.from(userDoc['friends']);
        if (!friends.contains(friendId)) {
          friends.add(friendId);
          await userRef.update({'friends': friends});
        }
      }
    } catch (err) {
      print(err);
    }
  }
}
