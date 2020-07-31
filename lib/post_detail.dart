import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/home_screen.dart';

import 'reply_detail.dart';
import 'replyer_communication.dart';

class PostDetail extends StatelessWidget {
  String postId;
  PostDetail({this.postId});

  Future<String> currentUserId() async {
    final user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  bool isPostUserCheck(
      currentUser, String originalPostUser, String replyPostUser) {
    if ((currentUser == originalPostUser) || (currentUser == replyPostUser)) {
      return true;
    }
    return false;
  }

  Future getPost(String postId) async {
    DocumentSnapshot post =
        await Firestore.instance.collection('posts').document(postId).get();
    return post.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('投稿詳細'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: FutureBuilder(
          future: getPost(postId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: ListView(
                  children: <Widget>[
                    Text(
                      'タイトル',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    Text(
                      '${snapshot.data['title']}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '詳細',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                    ),
                    Text(
                      '${snapshot.data['body']}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text('以下、ご相談に関する返信'),
                    ),
                    FutureBuilder<QuerySnapshot>(
                        future: Firestore.instance
                            .collection('posts/$postId/reply')
                            .orderBy('createdAt')
                            .getDocuments(),
                        builder: (context, replySnapshot) {
                          if (replySnapshot.hasData) {
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                // map()リスト型にしてループ
                                children:
                                    replySnapshot.data.documents.map((doc) {
                                  if (doc.data == null) {
                                    // TODO no reply表示する
                                    return Text('no reply');
                                  } else {
                                    return Container(
                                      width: 100,
                                      child: GestureDetector(
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ReplyDetail(
                                              replyPostId: doc.documentID,
                                              originalPostId:
                                                  doc.data['originalPostId'],
                                              replyUserId:
                                                  doc.data['replyUserId'],
                                              originalPostUser: doc
                                                  .data['originalPostUserId'],
                                            ),
                                            // builder: (context) => null,
                                          ),
                                        ),
                                        child: Card(
                                          child: Container(
                                            padding: EdgeInsets.all(24.0),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                        '${doc.data['replyUserName']}'),
                                                    Text(
                                                      '${doc.data['createdAt'].toDate().toString().substring(0, 19)}',
                                                      style: TextStyle(
                                                          fontSize: 9.0),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 24.0, 0, 24.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      '${doc.data['body']}',
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ),
                                                FutureBuilder<DocumentSnapshot>(
                                                  future: Firestore.instance
                                                      .collection('posts')
                                                      .document(
                                                          '${doc.data['originalPostId']}')
                                                      .get(),
                                                  builder:
                                                      (context, dsnapshot) {
                                                    if (dsnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    } else {
                                                      // print(doc.data[
                                                      //     'originalPostUserId']);
                                                      // print(dsnapshot
                                                      //     .data['replyUserId']);
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          FutureBuilder(
                                                            future:
                                                                currentUserId(),
                                                            builder: (context,
                                                                userSnapshot) {
                                                              if (userSnapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return Center(
                                                                    child:
                                                                        CircularProgressIndicator());
                                                              } else {
                                                                final currentUserId =
                                                                    userSnapshot
                                                                        .data;
                                                                return Row(
                                                                  children: <
                                                                      Widget>[
                                                                    isPostUserCheck(
                                                                            currentUserId,
                                                                            doc.data[
                                                                                'originalPostUserId'],
                                                                            dsnapshot.data[
                                                                                'replyUserId'])
                                                                        ? GestureDetector(
                                                                            child:
                                                                                Icon(
                                                                              Icons.chat_bubble_outline,
                                                                              size: 12.0,
                                                                            ),
                                                                            onTap: () =>
                                                                                Navigator.of(context).push(
                                                                              MaterialPageRoute(
                                                                                builder: (context) => ReplyerCommunication(
                                                                                  originalPostUserId: doc.data['originalPostUserId'],
                                                                                  originalPostId: doc.data['originalPostId'],
                                                                                  currentUserId: userSnapshot.data,
                                                                                  replyUserId: doc.data['replyUserId'],
                                                                                  replyPostId: doc.data['replyPostId'],
                                                                                  replyDocumentId: doc.documentID,
                                                                                  replyUserName: doc.data['replyUserName'],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Text(
                                                                            ''),
                                                                    // Container(
                                                                    //   padding: EdgeInsets.only(
                                                                    //       left:
                                                                    //           9.0),
                                                                    //   child:
                                                                    //       Row(
                                                                    //     mainAxisAlignment:
                                                                    //         MainAxisAlignment.start,
                                                                    //     children: <
                                                                    //         Widget>[
                                                                    //       Text(
                                                                    //         'いいね',
                                                                    //         style:
                                                                    //             TextStyle(fontSize: 10.0),
                                                                    //       ),
                                                                    //       Padding(
                                                                    //         padding:
                                                                    //             const EdgeInsets.only(left: 3.0),
                                                                    //         child:
                                                                    //             Text(
                                                                    //           '21',
                                                                    //           style: TextStyle(fontSize: 10.0),
                                                                    //         ),
                                                                    //       ),
                                                                    //     ],
                                                                    //   ),
                                                                    // ),
                                                                  ],
                                                                );
                                                              }
                                                            },
                                                          ),
                                                          // Align(
                                                          //   alignment: Alignment
                                                          //       .bottomRight,
                                                          //   child: Icon(
                                                          //     Icons.dehaze,
                                                          //     size: 18.0,
                                                          //   ),
                                                          // ),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }).toList());
                          } else {
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  Center(
                                    child: CircularProgressIndicator(),
                                    widthFactor: 20.0,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(top: 16),
                                    child: Text('Awaiting result...'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Container(
                child: Center(
                  child: Text('errorが発生しました'),
                ),
              );
            } else {
              return Container(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(),
                      widthFactor: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 16),
                      child: Text('Awaiting result...'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
