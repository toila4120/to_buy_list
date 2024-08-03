import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:to_buy_list/Screen/DetailList.dart';
import 'package:to_buy_list/model/ToBuyList.dart';
import 'package:to_buy_list/services/BuyListServices.dart';
import 'package:to_buy_list/services/UserProvider.dart';
import 'package:to_buy_list/widget/SnakBar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _nameListController = TextEditingController();
  final List<GlobalKey<_NewItemState>> _itemKeys = [];
  DateTime? _selectedDate;
  late BuyListServices _buyListServices;
  String _luuY = '';

  @override
  void initState() {
    super.initState();
    _buyListServices = BuyListServices();
  }

  Future<Stream<List<ToBuyList>>> _fetchToBuyList() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.uid;
    return await _buyListServices.getToBuyListStream(myId: userId);
  }

  void _addNewItem(StateSetter updateState) {
    final key = GlobalKey<_NewItemState>();
    updateState(() {
      _itemKeys.add(key);
    });
  }

  Future<void> _createToBuyList(String userId) async {
    final listName = _nameListController.text;
    if (listName.isEmpty || _selectedDate == null) {
      setState(() {
        _luuY = 'Vui lòng nhập tên danh sách và chọn ngày hết hạn';
      });
      return;
    }

    try {
      final listId = await _buyListServices.createToBuyList(
        userId,
        listName,
        _selectedDate!,
      );

      for (final key in _itemKeys) {
        final item = key.currentState?.getItem();
        if (item != null) {
          await _buyListServices.addItemToList(listId, item.itemName);
        }
      }

      showSnackBar(context, 'Danh sách đã được tạo thành công');
      setState(() {
        _nameListController.clear();
        _itemKeys.clear();
        _selectedDate = null;
        _luuY = '';
      });
      Navigator.of(context).pop();
    } catch (e) {
      print('Error creating To-buy-list: $e');
      showSnackBar(context, 'Lỗi khi tạo danh sách');
    }
  }

  void _showAddTaskBottomSheet(String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FTextField(
                        hint: 'Nhập tên danh sách mua tại đây',
                        controller: _nameListController,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: _itemKeys
                            .map((key) => NewItem(
                                key: key,
                                onRemove: () {
                                  setState(() {
                                    _itemKeys.remove(key);
                                  });
                                }))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      if (_luuY.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Lưu ý: $_luuY',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final DateTime now = DateTime.now();
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate:
                                    now.subtract(const Duration(days: 1)),
                                lastDate: DateTime(now.year + 1),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                  _luuY = '';
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              _addNewItem(setState);
                            },
                            icon: const Icon(Icons.add_task),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () => _createToBuyList(userId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool checkUpdate(ToBuyList toBuyList) {
    final user = Provider.of<UserProvider>(context).user;
    for (var list in toBuyList.sharedWith) {
      if (list.uidUser == user!.uid && list.read) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddTaskBottomSheet(user!.uid);
          },
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<List<ToBuyList>>(
          stream: _buyListServices.getToBuyListStream(myId: user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Bạn chưa có danh sách mua nào, hãy thêm bên dưới'),
              );
            } else {
              final toBuyList = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: toBuyList.length,
                      itemBuilder: (context, index) {
                        var list = toBuyList[index];
                        return ListTile(
                          title: Text(list.name),
                          subtitle:
                              Text('Hạn: ${list.expirationDate.toDate()}'),
                          trailing: checkUpdate(list)
                              ? null
                              : Icon(Icons.circle, color: Colors.red, size: 10),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Detaillist(
                                  buyList: list,
                                  callback: () {
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class NewItem extends StatefulWidget {
  const NewItem({Key? key, required this.onRemove}) : super(key: key);
  final VoidCallback onRemove;

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final TextEditingController _itemController = TextEditingController();

  Item? getItem() {
    final itemName = _itemController.text;
    if (itemName.isEmpty) return null;
    return Item(
      itemName: itemName,
      isBought: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _itemController,
              decoration: const InputDecoration(hintText: 'Đồ cần mua'),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
            ),
          ),
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
