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

      await _firestore.collection('to_buy_lists').doc(docRef.id).update({
        'listId': docRef.id,
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

  Stream<List<ToBuyList>> getToBuyListStream({required String myId}) {
    return _firestore
        .collection('to_buy_lists')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => ToBuyList.fromDocument(doc))
          .where((list) {
        return list.ownerId == myId ||
            list.sharedWith.any((user) => user.uidUser == myId);
      }).toList();
    });
  }

  Future<void> updateSharedWith(String listId, String uidUser) async {
    try {
      await _firestore.collection('to_buy_lists').doc(listId).update({
        'sharedWith': FieldValue.arrayUnion([
          {'uidUser': uidUser, 'read': false}
        ]),
      });
    } catch (e) {
      print("Error updating sharedWith: $e");
    }
  }

  Future<void> saveUpdate(ToBuyList toBuyList) async {
    try {
      await _firestore.collection('to_buy_lists').doc(toBuyList.listId).update({
        'listName': toBuyList.name,
        'expirationDate': toBuyList.expirationDate,
        'items': toBuyList.items.map((item) => item.toMap()).toList(),
        'sharedWith': toBuyList.sharedWith
            .map((user) => {'uidUser': user.uidUser, 'read': user.read})
            .toList(),
      });
    } catch (e) {
      print("Error saving updates: $e");
      throw Exception('Error saving updates to To-buy-list');
    }
  }

  Future<void> saveRead(ToBuyList toBuyList, String myid, bool ktra) async {
    try {
      List<SharedWith> updatedSharedWith =
          toBuyList.sharedWith.map((shareWith) {
        if (ktra) {
          if (shareWith.uidUser != myid) {
            shareWith.read = false;
          }
        } else {
          if (shareWith.uidUser == myid) {
            shareWith.read = true;
          }
        }
        return shareWith;
      }).toList();

      await _firestore.collection('to_buy_lists').doc(toBuyList.listId).update({
        'sharedWith': updatedSharedWith.map((e) => e.toMap()).toList(),
      });
    } catch (e) {
      print("Error saving updates: $e");
      throw Exception('Error saving updates to To-buy-list');
    }
  }
}
