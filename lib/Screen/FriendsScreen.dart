import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_buy_list/model/User.dart';
import 'package:to_buy_list/services/Authentication.dart';
import 'package:to_buy_list/services/UserProvider.dart';
import 'package:to_buy_list/widget/SnakBar.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _nameController = TextEditingController();
  User? user;
  bool _ktra = false;
  List<User> friendsList = [];
  List<User> searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadFriendsList();
  }

  Future<void> _loadFriendsList() async {
    final myUser = Provider.of<UserProvider>(context, listen: false).user;
    if (myUser != null) {
      try {
        friendsList = await AuthServices().getFriendsList(userId: myUser.uid);
        setState(() {});
      } catch (e) {
        print('Error loading friends list: $e');
        showSnackBar(context, 'Lỗi khi tải danh sách bạn bè');
      }
    }
  }

  void searchUser(String myId) async {
    User? user1 =
        await AuthServices().searchUser(nameOrEmail: _nameController.text);
    if (user1 == null) {
      showSnackBar(context, 'Không tìm thấy người này');
      setState(() {
        searchResults = [];
      });
    } else {
      bool _ktra1 =
          await AuthServices().ktraban(userId: myId, friendId: user1.uid);
      if (myId == user1.uid) {
        setState(() {
          _ktra1 = true;
          searchResults = [];
        });
        showSnackBar(context, 'Đây là tài khoản đăng nhập');
      } else {
        setState(() {
          _ktra = _ktra1;
          searchResults = [user1];
        });
      }
    }
  }

  void addFriend(String myID, String friendId) async {
    await AuthServices().addFriend(userId: myID, friendId: friendId);
    await AuthServices().addFriend(userId: friendId, friendId: myID);
    showSnackBar(context, 'Thêm bạn thành công');
    _loadFriendsList();
  }

  @override
  Widget build(BuildContext context) {
    final myUser = Provider.of<UserProvider>(context).user;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            _nameController.clear();
                          },
                          icon: const Icon(Icons.clear),
                        ),
                        hintText: 'Nhập email hoặc tên để tìm kiếm',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (myUser != null) {
                        searchUser(myUser.uid);
                      } else {
                        showSnackBar(
                            context, 'Không thể xác định người dùng hiện tại');
                      }
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              friendsList.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Danh sách bạn bè',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: friendsList.length,
                          itemBuilder: (context, index) {
                            final friend = friendsList[index];
                            return ListTile(
                              title: Text(friend.nickname),
                              subtitle: Text(friend.email),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Text(
                                  friend.nickname.substring(0, 1),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : const Center(child: Text('Chưa có bạn bè nào')),
              const SizedBox(height: 16),
              searchResults.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kết quả tìm kiếm',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final searchUser = searchResults[index];
                            return ListTile(
                              title: Text(searchUser.nickname),
                              subtitle: Text(searchUser.email),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Text(
                                  searchUser.nickname.substring(0, 1),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              trailing: !_ktra
                                  ? IconButton(
                                      onPressed: () {
                                        if (myUser != null) {
                                          addFriend(myUser.uid, searchUser.uid);
                                        } else {
                                          showSnackBar(context,
                                              'Không thể thêm bạn lúc này');
                                        }
                                      },
                                      icon: const Icon(Icons.add),
                                    )
                                  : const SizedBox(width: 0),
                            );
                          },
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
