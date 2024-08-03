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

  ToBuyList copyWith({
    String? listId,
    String? name,
    String? ownerId,
    Timestamp? expirationDate,
    List<SharedWith>? sharedWith,
    List<Item>? items,
  }) {
    return ToBuyList(
      listId: listId ?? this.listId,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      expirationDate: expirationDate ?? this.expirationDate,
      sharedWith: sharedWith ?? this.sharedWith,
      items: items ?? this.items,
    );
  }

  factory ToBuyList.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ToBuyList(
      listId: data['listId'] ?? '',
      name: data['listName'] ?? '',
      ownerId: data['userId'] ?? '',
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

  Map<String, dynamic> toMap() {
    return {
      'listId': listId,
      'listName': name,
      'userId': ownerId,
      'expirationDate': expirationDate,
      'sharedWith': sharedWith.map((item) => item.toMap()).toList(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class SharedWith {
  final String uidUser;
  bool read;

  SharedWith({
    required this.uidUser,
    required this.read,
  });

  factory SharedWith.fromMap(Map<String, dynamic> map) {
    return SharedWith(
      uidUser: map['uidUser'] ?? '',
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uidUser': uidUser,
      'read': read,
    };
  }
}

class Item {
  String itemName;
  bool isBought;
  String? boughtBy;

  Item({
    required this.itemName,
    required this.isBought,
    this.boughtBy,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemName: map['itemName'] ?? '',
      isBought: map['isBought'] ?? false,
      boughtBy: map['boughtBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'isBought': isBought,
      'boughtBy': boughtBy,
    };
  }

  Item copyWith({
    String? itemName,
    bool? isBought,
    String? boughtBy,
  }) {
    return Item(
      itemName: itemName ?? this.itemName,
      isBought: isBought ?? this.isBought,
      boughtBy: boughtBy ?? this.boughtBy,
    );
  }
}
