import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bottom_navigation.dart';

class Block extends StatelessWidget {
  String postId;
  Block({this.postId});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> getCurrentUserId() async {
    var user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  addPostBlockUid() async {
    var uid = await getCurrentUserId();
    var documentRef = Firestore.instance.collection('posts').document(postId);

    documentRef.setData({
      'block': FieldValue.arrayUnion([uid])
    }, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ブロック'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text("本当にブロックしますか？"),
          ),
          Center(
            child: RaisedButton(
              child: Text("ブロックする"),
              color: Colors.orange,
              textColor: Colors.white,
              onPressed: () {
                addPostBlockUid();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BottomNavigation(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
