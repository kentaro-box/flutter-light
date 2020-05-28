import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnonymousAuthorization {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _userCollectionRef = Firestore.instance.collection('users');

  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
      final FirebaseUser user = (await _firebaseAuth.currentUser());

      var userId = user.uid;
      final usersSnapshot = await _userCollectionRef.document(userId).get();
      if (!usersSnapshot.exists) {
        _userCollectionRef.document(userId).setData({
          'userName': null,
          'userId': user.uid,
          'createdAt': new DateTime.now(),
          'category': 'consulter',
          // TODO 匿名認証の名前どうする？
          // TODO 匿名認証ログインするたびuid変わる
        });
      }
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
