import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/make_post.dart';

import 'bottom_navigation.dart';

class Reply extends StatelessWidget {
  String postDocumentId;
  String originalPostUserId;
  String reply;
  Reply({this.postDocumentId, this.originalPostUserId});

  TextEditingController _replyTextController = TextEditingController();
  MakePost _makePost = MakePost();

  final _auth = FirebaseAuth.instance;
  final postCollectionRef = Firestore.instance.collection('posts');
  getUserData(uid) async {
    final userDocument =
        await Firestore.instance.collection('users').document(uid).get();

    var userRecord = userDocument.data;

    return userRecord;
  }

  currentUserData(
      reply, documentId, originalUserId, BuildContext context) async {
    var currentUser = await _auth.currentUser();
    var curentUserInfo = await getUserData(currentUser.uid);
    var userName = await curentUserInfo['userName'];
    var created = new DateTime.now();

    var replyData = {
      'replyUserId': currentUser.uid,
      'replyUserName': userName,
      'createdAt': created,
      'body': reply,
      'replyPostId': new DateTime.now().toString() + currentUser.uid,
      'originalPostId': documentId,
      'originalPostUserId': originalPostUserId,
    };
    var replySubCollection =
        postCollectionRef.document(documentId).collection('reply').document();
    final batch = Firestore.instance.batch();
    batch.setData(postCollectionRef.document(documentId),
        {'replyCount': FieldValue.increment(1)},
        merge: true);
    batch.setData(replySubCollection, replyData, merge: true);
    try {
      batch.commit();
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('投稿が出来ませんでした'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('返信'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 0),
                color: Colors.white.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: _replyTextController,
                      onChanged: (String reply) {
                        reply = _replyTextController.text;
                      },
                      decoration: InputDecoration(
                        labelText: '返信',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.lightBlue[200],
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 40,
                margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Builder(builder: (context) {
                  return RaisedButton(
                    color: Colors.lightBlue[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      var originalUserId = originalPostUserId;
                      var documentId = postDocumentId;
                      currentUserData(_replyTextController.text, documentId,
                          originalUserId, context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => BottomNavigation(),
                        ),
                      );
                    },
                    child: Text(
                      '投稿',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          letterSpacing: 9.0),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
