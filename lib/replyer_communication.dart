import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bottom_navigation.dart';
import 'home_screen.dart';
import 'reply_detail.dart';

class ReplyerCommunication extends StatelessWidget {
  ReplyerCommunication({
    this.originalPostUserId,
    this.originalPostId,
    this.currentUserId,
    this.replyUserId,
    this.replyPostId,
    this.replyDocumentId,
    this.replyUserName,
  });
  String originalPostUserId;
  String originalPostId;
  String currentUserId;
  String replyUserId;
  String replyPostId;
  String replyDocumentId;
  String replyUserName;
  String userName;

  TextEditingController _communicationTextController = TextEditingController();

  Future<Map<String, dynamic>> getPostUserDetails() async {
    final user = await FirebaseAuth.instance.currentUser();

    final userDetails = {
      'userName': user.displayName,
      'userId': user.uid,
    };
    return userDetails;
  }

  // currentUserName() {
  //   final user =
  //       Firestore.instance.collection('users').document(currentUserId).get();
  //   return user['userName'];
  // }

  writeCommunicationData(data, documentId) async {
    final communicationCollectionRef = Firestore.instance
        .collection('posts')
        .document(originalPostId)
        .collection('reply')
        .document(documentId)
        .collection('communication')
        .document();

    final userDetail = await getPostUserDetails();

    var communicationData = {
      'originalPostUserId': originalPostUserId,
      'originalPostId': originalPostId,
      'replyUserId': replyUserId,
      'replyPostId': replyPostId,
      'replyUserName': userDetail['userName'],
      'replyDocumentId': documentId,
      'createdAt': new DateTime.now(),
      'communicatePostUser': userDetail['userId'],
      'communicationPostId': new DateTime.now().toString() + currentUserId,
      'body': data,
    };

    communicationCollectionRef.setData(communicationData, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('相談への投稿'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 0),
            color: Colors.white.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _communicationTextController,
                onChanged: (String communication) {
                  communication = _communicationTextController.text;
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
                  writeCommunicationData(
                      _communicationTextController.text, replyDocumentId);
                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(
                  //     builder: (context) => BottomNavigation(),
                  //   ),
                  // );
                  Navigator.of(context).pop();
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
    );
  }
}
