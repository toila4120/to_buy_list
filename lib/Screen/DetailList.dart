import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_buy_list/model/ToBuyList.dart';
import 'package:to_buy_list/model/User.dart';
import 'package:to_buy_list/services/Authentication.dart';
import 'package:to_buy_list/services/BuyListServices.dart';
import 'package:to_buy_list/services/UserProvider.dart';
import 'package:to_buy_list/widget/SnakBar.dart';

class Detaillist extends StatefulWidget {
  final ToBuyList buyList;
  final Function? callback;
  Detaillist({Key? key, required this.buyList, this.callback})
      : super(key: key);

  @override
  State<Detaillist> createState() => _DetaillistState();
}

class _DetaillistState extends State<Detaillist> {
  late ToBuyList _editableList;
  List<User> friendsList = [];

  @override
  void initState() {
    super.initState();
    _updateRead();
    _editableList = widget.buyList;
    _loadFriendsList();
  }

  Future<void> _updateRead() async {
    final myUser = Provider.of<UserProvider>(context, listen: false).user;
    await BuyListServices().saveRead(widget.buyList, myUser!.uid, false);
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

  Future<void> _showAddItemDialog() async {
    final TextEditingController _itemNameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm mục mới'),
          content: TextField(
            controller: _itemNameController,
            decoration: const InputDecoration(hintText: 'Tên mục'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final newItemName = _itemNameController.text.trim();
                if (newItemName.isNotEmpty) {
                  setState(() {
                    _editableList.items
                        .add(Item(itemName: newItemName, isBought: false));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  bool isUserInSharedWith(String userId, ToBuyList toBuyList) {
    return toBuyList.sharedWith.any((shared) => shared.uidUser == userId);
  }

  Future<void> _showFriendsDialog() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn bạn để chia sẻ'),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: friendsList.length,
              itemBuilder: (context, index) {
                final friend = friendsList[index];
                return ListTile(
                  title: Text(friend.nickname),
                  subtitle: Text('Email: ${friend.email}'),
                  onTap: () async {
                    bool ktra = isUserInSharedWith(friend.uid, _editableList);
                    if (ktra) {
                      Navigator.pop(context);
                      showSnackBar(
                          context, '${friend.nickname} đã có trong danh sách');
                    } else {
                      await BuyListServices()
                          .updateSharedWith(_editableList.listId, friend.uid);
                      SharedWith addWith =
                          SharedWith(read: false, uidUser: friend.uid);
                      setState(() {
                        _editableList.sharedWith.add(addWith);
                      });
                      Navigator.pop(context);
                      showSnackBar(
                          context, 'Đã thêm ${friend.nickname} vào danh sách');
                    }
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    final myUser = Provider.of<UserProvider>(context, listen: false).user;
    try {
      await BuyListServices().saveUpdate(_editableList);
      await BuyListServices().saveRead(widget.buyList, myUser!.uid, true);
      showSnackBar(context, 'Danh sách đã được cập nhật thành công');
    } catch (e) {
      print('Error saving changes: $e');
      showSnackBar(context, 'Lỗi khi lưu danh sách');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
                widget.callback?.call();
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text(
            widget.buyList.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (_editableList.items.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _editableList.items.length,
                  itemBuilder: (context, index) {
                    final item = _editableList.items[index];
                    return ListTile(
                      title: Text(
                        item.itemName,
                        style: TextStyle(
                          decoration: item.isBought
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: item.isBought
                          ? Text('Mua bởi: ${item.boughtBy}')
                          : null,
                      trailing: Checkbox(
                        value: item.isBought,
                        onChanged: (bool? value) {
                          if (value!) {
                            setState(() {
                              _editableList.items[index].boughtBy =
                                  user!.nickname;
                              _editableList.items[index].isBought = value;
                            });
                          } else {
                            setState(() {
                              _editableList.items[index].boughtBy = null;
                              _editableList.items[index].isBought = value;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      _showFriendsDialog();
                    },
                    icon: const Icon(Icons.group_add),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _showAddItemDialog();
                    },
                    icon: const Icon(Icons.add_task_outlined),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _saveChanges();
                      // Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
