import 'package:cloud_firestore/cloud_firestore.dart';

class BuyListServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Tạo To-buy-list
  Future<void> createToBuyList(
      String userId, String listName, DateTime expirationDate) async {
    try {
      await _firestore.collection('to_buy_lists').add({
        'userId': userId,
        'listName': listName,
        'expirationDate': expirationDate,
        'items': [],
        'sharedWith': [],
      });
    } catch (e) {
      print(e);
    }
  }

// Thêm mục vào danh sách
  Future<void> addItemToList(String listId, String itemName) async {
    try {
      await _firestore.collection('to_buy_lists').doc(listId).update({
        'items': FieldValue.arrayUnion([
          {'name': itemName, 'boughtBy': null}
        ]),
      });
    } catch (e) {
      print(e);
    }
  }
}
