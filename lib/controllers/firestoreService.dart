import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transactionlog.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setMainAmount(int amount) async {
    await _firestore.collection('budget').doc('mainamount').set({'amount': amount});
  }

  Future<int> getMainAmount() async {
    var document = await _firestore.collection('budget').doc('mainamount').get();
    print(document);
    print(document['amount']);
    return document['amount'];
  }

  Future<void> addTransaction(int amount, bool isDeposit) async {
    int currentAmount = await getMainAmount();

    if (isDeposit) {
      currentAmount += amount;
    } else {
      currentAmount -= amount;
    }

    await setMainAmount(currentAmount);
  }

  Future<void> addTransactionLog(String username, int amount, bool isDeposit, String description) async {
    String type = isDeposit ? 'deposit' : 'withdraw';
    DateTime now = DateTime.now();
    String datetime = now.toIso8601String();

    await _firestore.collection('transactions').add({
      'username': username,
      'datetime': datetime,
      'amount': amount,
      'type': type,
      'mainamountafter': await getMainAmount(),
      'description' : description,
    });
  }

  Future<List<TransactionLogWithId>> getTransactionLogsWithIds() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('transactions').get();

    return querySnapshot.docs.map((doc) {
      return TransactionLogWithId(
        id: doc.id,
        username: doc['username'],
        amount: doc['amount'],
        type: doc['type'],
        datetime: doc['datetime'],
        mainAmount: doc['mainamountafter'],
        description: doc['description'],
      );
    }).toList();
  }

  Future<void> updateTransactionDescription(String transactionId, String newDescription) async {
    await FirebaseFirestore.instance.collection('transactions').doc(transactionId).update({
      'description': newDescription,
    });
  }

  Future<void> deleteTransaction(String transactionId) async {
    await FirebaseFirestore.instance.collection('transactions').doc(transactionId).delete();
  }

  Future<String?> getUserName(String? email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming 'email' is a unique field, so there should be at most one document
        var document = querySnapshot.docs.first;
        print(document.data()['name']);
        return document.data()['name'];
        return document.data()['rank'];
      } else {
        // No user found with the provided email
        print("no users found??");
        return "STRH";
      }
    } catch (e) {
      // Handle any errors that occurred during the query
      print("Error getting username: $e");
      return "STRH";
    }
  }

  Future<String?> getUserRank(String? email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming 'email' is a unique field, so there should be at most one document
        var document = querySnapshot.docs.first;
        print(document.data()['rank']);
        return document.data()['rank'];
      } else {
        // No user found with the provided email
        print("no users found??");
        return "User";
      }
    } catch (e) {
      // Handle any errors that occurred during the query
      print("Error getting username: $e");
      return "User";
    }
  }

}
