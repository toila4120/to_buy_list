import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_buy_list/model/ToBuyList.dart';
import 'package:to_buy_list/services/UserProvider.dart';

class Detaillist extends StatefulWidget {
  final ToBuyList buyList;

  const Detaillist({Key? key, required this.buyList}) : super(key: key);

  @override
  State<Detaillist> createState() => _DetaillistState();
}

class _DetaillistState extends State<Detaillist> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.buyList.name,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.buyList.items.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.buyList.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.buyList.items[index];
                    return ListTile(
                      title: Text(item.itemName),
                      trailing: Checkbox(
                        value: item.isBought,
                        onChanged: (bool? value) {
                          setState(() {
                            widget.buyList.items[index] = item.copyWith(
                              isBought: value!,
                              boughtBy: value ? user!.nickname : null,
                            );
                          });
                        },
                      ),
                    );
                  },
                ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      // Add functionality to add a user to the list
                    },
                    icon: Icon(Icons.group_add),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // Add functionality to add a new task
                    },
                    icon: Icon(Icons.add_task_outlined),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // Add functionality to save changes
                    },
                    icon: Icon(Icons.save),
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
