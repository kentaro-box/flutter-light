import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'replyer_communication.dart';

class ReplyDetail extends StatelessWidget {
  String replyPostId;
  String replyUserId;
  String originalPostUser;
  String originalPostId;

  ReplyDetail({
    this.replyPostId,
    this.replyUserId,
    this.originalPostUser,
    this.originalPostId,
  });

  Future<String> currentUserId() async {
    final user = await FirebaseAuth.instance.currentUser();

    return user.uid;
  }

  isUserCheck(uid) {
    if (originalPostUser == uid || replyUserId == uid) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('やり取り詳細'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
          ),
          actions: <Widget>[
            // TODO consulterは非表示
            FutureBuilder(
              future: currentUserId(),
              builder: (context, uidSnapshot) {
                if (uidSnapshot.hasData) {
                  return IconButton(
                    icon: const Icon(
                      Icons.create,
                      color: Colors.green,
                    ),
                    tooltip: 'Show Snackbar',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReplyerCommunication(
                          originalPostId: originalPostId,
                          replyPostId: replyPostId,
                          replyUserId: replyUserId,
                          originalPostUserId: originalPostUser,
                          currentUserId: uidSnapshot.data,
                          replyDocumentId: replyPostId,
                        ),
                        // builder: (context) => null,
                      ),
                    ),
                  );
                } else {
                  return Text('');
                }
              },
            ),
          ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('posts')
            .document(originalPostId)
            .collection('reply')
            .document(replyPostId)
            .collection('communication')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView(
              children: snapshot.data.documents.map((documentData) {
                if (!documentData.exists) {
                  return Text('noData');
                } else {
                  return Container(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('${documentData.data['replyUserName']}'),
                            Text(
                              '${documentData.data['createdAt'].toDate().toString().substring(0, 19)}',
                              style: TextStyle(fontSize: 9.0),
                            )
                          ],
                        ),
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Text('${documentData.data['body']}')),
                        Divider(),
                      ],
                    ),
                  );
                }
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
