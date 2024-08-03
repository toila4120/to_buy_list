// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:to_buy_list/model/User.dart';
// import 'package:to_buy_list/services/Authentication.dart';
// import 'package:to_buy_list/services/UserProvider.dart';
// import 'package:to_buy_list/widget/SnakBar.dart';

// class Addfriendtolist extends StatelessWidget {
//   Addfriendtolist({super.key});

//   List<User> friendsList = [];
//   Future<void> _loadFriendsList() async {
//     final myUser = Provider.of<UserProvider>(context, listen: false).user;
//     if (myUser != null) {
//       try {
//         friendsList = await AuthServices().getFriendsList(userId: myUser.uid);
//       } catch (e) {
//         print('Error loading friends list: $e');
//         showSnackBar(context, 'Lỗi khi tải danh sách bạn bè');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomSheet(
//       builder: (context) {},
//     );
//   }
// }
