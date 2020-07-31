import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/is_check_post.dart';
import 'package:flutter_bbs/main.dart';
import 'package:flutter_bbs/make_post.dart';
import 'package:flutter_bbs/post_detail.dart';
import 'package:flutter_bbs/reply.dart';
import 'edit_and_delete.dart';
import 'firestore/connect_firestore_post.dart';
import 'report.dart';
import 'word_of_today.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ConnectFirestorePost _connectFirestore = ConnectFirestorePost();
  IsCheckPost _isCheckPost = IsCheckPost();
  String userCategory;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> getCurrentUserId() async {
    var user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  Future<String> getCategory() async {
    var uid = await getCurrentUserId();
    var userInfo =
        await Firestore.instance.collection('users').document(uid).get();
    var userCategory = userInfo.data;
    return userCategory['category'];
  }

  checkBlock() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('home'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
          ),
          actions: <Widget>[
            //   FlatButton(
            //     onPressed: () async {
            //       await FirebaseAuth.instance.signOut();
            //       Navigator.of(context).pushAndRemoveUntil(
            //           MaterialPageRoute(builder: (context) => SplashScreen()),
            //           (Route<dynamic> route) => false);
            //     },
            //     child: Text('ログアウト'),
            //   ),
            // TODO アドバイザーは非表示
            IconButton(
              icon: const Icon(
                Icons.create,
                color: Colors.green,
              ),
              tooltip: 'Show Snackbar',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MakePost(),
                ),
              ),
            ),
          ]),
      body: FutureBuilder<Object>(
          future: getCurrentUserId(),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            // print(futureSnapshot);
            final uid = futureSnapshot.data;
            return Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: _connectFirestore.firestoreGetPosts,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView(
                      children: snapshot.data.documents.map((post) {
                        // print(post.data['block']);

                        if (post.data['block'].toString() == '[${uid}]') {
                          return Card(
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 9.0, 0, 9.0),
                                child: Text('非表示にしたコンテンツです'),
                              ),
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetail(postId: post.documentID),
                            ),
                          ), // 各投稿の全文及、返信を読める。
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        '${post['user']['userName']} さん',
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                      Text(
                                        '${post['createdAt'].toDate().toString().substring(0, 19)}',
                                        style: TextStyle(fontSize: 9.0),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 16.0, 0, 8.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            post['title'],
                                            style: TextStyle(fontSize: 16.0),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8.0, 0, 16),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            post['body'],
                                            overflow: TextOverflow
                                                .ellipsis, // TODO ... (readmoreみたいな)
                                            maxLines: 3,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          FutureBuilder(
                                              future: getCategory(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                } else {
                                                  return Container(
                                                    padding: EdgeInsets.only(
                                                        right: 16.0),
                                                    child: _isCheckPost
                                                            .isUserCategory(
                                                                snapshot.data)
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                  builder: (context) => Reply(
                                                                      postDocumentId:
                                                                          post
                                                                              .documentID,
                                                                      originalPostUserId:
                                                                          '${post['user']['userId']}'),
                                                                ),
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .chat_bubble_outline,
                                                              size: 12.0,
                                                            ),
                                                          )
                                                        : Text(''),
                                                  );
                                                }
                                              }),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                '返信数',
                                                style:
                                                    TextStyle(fontSize: 10.0),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        3.0, 4.0, 0, 0),
                                                child: Text(
                                                    '${post['replyCount']}',
                                                    style: TextStyle(
                                                        fontSize: 10.0)),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      FutureBuilder(
                                        future: getCurrentUserId(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final currentUserId = snapshot.data;
                                            return _isCheckPost.isMyPost(
                                                    '${post['user']['userId']}',
                                                    currentUserId)
                                                ? GestureDetector(
                                                    child: Icon(
                                                      Icons.dehaze,
                                                      size: 18.0,
                                                    ),
                                                    onTap: () async {
                                                      var result =
                                                          await Navigator.of(
                                                                  context)
                                                              .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditAndDelete(
                                                                  postId: post
                                                                      .documentID),
                                                        ),
                                                      );
                                                      if (result == true) {
                                                        TabInherited.of(context)
                                                            .openTab(0);
                                                      }
                                                    })
                                                : GestureDetector(
                                                    child: Icon(
                                                      Icons.more_vert,
                                                      size: 18.0,
                                                    ),
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Report(
                                                                postId: post
                                                                    .documentID),
                                                      ),
                                                    ),
                                                  );
                                          } else {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            );
          }),
    );
  }
}
