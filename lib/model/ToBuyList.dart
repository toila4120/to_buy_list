import 'package:cloud_firestore/cloud_firestore.dart';

class ToBuyList {
  final String listId;
  final String name;
  final String ownerId;
  final Timestamp expirationDate;
  final List<SharedWith> sharedWith;
  final List<Item> items;

  ToBuyList({
    required this.listId,
    required this.name,
    required this.ownerId,
    required this.expirationDate,
    required this.sharedWith,
    required this.items,
  });

  // Tạo đối tượng ToBuyList từ tài liệu Firestore
  factory ToBuyList.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ToBuyList(
      listId: data['uid'] ?? '',
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      expirationDate: data['expirationDate'] as Timestamp,
      sharedWith: (data['sharedWith'] as List<dynamic>?)
              ?.map((item) => SharedWith.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => Item.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Chuyển đổi đối tượng ToBuyList thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': listId,
      'name': name,
      'ownerId': ownerId,
      'expirationDate': expirationDate,
      'sharedWith': sharedWith.map((item) => item.toMap()).toList(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class SharedWith {
  final String uidUser;
  final bool read;

  SharedWith({
    required this.uidUser,
    required this.read,
  });

  // Tạo đối tượng SharedWith từ Map
  factory SharedWith.fromMap(Map<String, dynamic> map) {
    return SharedWith(
      uidUser: map['uidUser'] ?? '',
      read: map['read'] ?? false,
    );
  }

  // Chuyển đổi đối tượng SharedWith thành Map
  Map<String, dynamic> toMap() {
    return {
      'uidUser': uidUser,
      'read': read,
    };
  }
}

class Item {
  final String itemName;
  final bool isBought;
  final String? boughtBy;

  Item({
    required this.itemName,
    required this.isBought,
    this.boughtBy,
  });

  // Tạo đối tượng Item từ Map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemName: map['itemName'] ?? '',
      isBought: map['isBought'] ?? false,
      boughtBy: map['boughtBy'],
    );
  }

  // Chuyển đổi đối tượng Item thành Map
  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'isBought': isBought,
      'boughtBy': boughtBy,
    };
  }
}
