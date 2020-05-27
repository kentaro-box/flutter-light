import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ConnectFirestoreUser {
  Firestore _firestore = Firestore.instance;

  // user登録
  createUser(collectionName, data) {
    return _firestore.collection(collectionName).document().setData(data);
  }

  // userName unique
  Future<bool> userNameCheck(String username) async {
    final result = await Firestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .getDocuments();
    return result.documents.isEmpty;
  }
}
