import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bottom_navigation.dart';

class Notice extends StatelessWidget {
  String postId;
  Notice({this.postId});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> getCurrentUserId() async {
    var user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  addReport() async {
    var uid = await getCurrentUserId();
    var collectionRef = Firestore.instance.collection('report');

    collectionRef.document().setData({
      'reportedPostId': postId,
      'uid': uid,
    }, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通報'),
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
            child: Text("本当に通報しますか？"),
          ),
          Center(
            child: RaisedButton(
                child: Text("通報する"),
                color: Colors.orange,
                textColor: Colors.white,
                onPressed: () {
                  addReport();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => BottomNavigation()),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
