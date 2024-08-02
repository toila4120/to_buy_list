import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_buy_list/model/ToBuyList.dart';

class BuyListServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createToBuyList(
      String userId, String listName, DateTime expirationDate) async {
    try {
      final docRef = await _firestore.collection('to_buy_lists').add({
        'userId': userId,
        'listName': listName,
        'expirationDate': expirationDate,
        'items': [],
        'sharedWith': [
          {'uidUser': userId, 'read': true}
        ],
      });

      return docRef.id;
    } catch (e) {
      print(e);
      throw Exception('Error creating To-buy-list');
    }
  }

  Future<void> addItemToList(String listId, String itemName) async {
    try {
      await _firestore.collection('to_buy_lists').doc(listId).update({
        'items': FieldValue.arrayUnion([
          {'itemName': itemName, 'isBought': false, 'boughtBy': null}
        ]),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<ToBuyList>> getToBuyList({required String myId}) async {
    List<ToBuyList> toBuyList = [];
    try {
      final allBuyList = await _firestore.collection('to_buy_lists').get();

      print("Owner Query Result: ${allBuyList.docs.length} documents found.");

      final allDocsSnapshot = await _firestore.collection('to_buy_lists').get();

      List<ToBuyList> toBuyList1 = [];
      toBuyList1 = allDocsSnapshot.docs
          .map((doc) => ToBuyList.fromDocument(doc))
          .toList();
      for (var list in toBuyList1) {
        if (list.ownerId == myId) {
          toBuyList.add(list);
        } else {
          for (var list1 in list.sharedWith) {
            if (list1.uidUser == myId) {
              toBuyList.add(list);
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching documents: $e");
    }
    return toBuyList;
  }
}
