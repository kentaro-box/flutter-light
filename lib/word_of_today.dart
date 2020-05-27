import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/home_screen.dart';
import 'package:flutter_bbs/post_word_of_today.dart';
import 'package:flutter_bbs/word_of_today_edit_and_del.dart';
import 'package:like_button/like_button.dart';

import 'is_check_post.dart';

class WordOfToday extends StatefulWidget {
  @override
  _WordOfTodayState createState() => _WordOfTodayState();
}

class _WordOfTodayState extends State<WordOfToday> {
  Firestore _firestore = Firestore.instance;
  HomeScreen homeScreen = HomeScreen();
  IsCheckPost _isCheckPost = IsCheckPost();
  int thanksCount;

  final Stream<QuerySnapshot> firestoreGetWordsAll = Firestore.instance
      .collection('wordOfToday')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<String> getCurrentUserId() async {
    var user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  // changeThankCount(docId, thanksCount) {
  //   _firestore.collection('wordOfToday').document(docId).setData({
  //     'thanksCount': thanksCount,
  //   }, merge: true);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('今日の一言'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
          ),
          actions: <Widget>[
            // TODO consulterは非表示
            IconButton(
                icon: const Icon(
                  Icons.create,
                  color: Colors.green,
                ),
                tooltip: 'Show Snackbar',
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostWordOfToday(),
                    ),
                  );
                  if (result == true) {
                    TabInherited.of(context).openTab(1);
                  }
                }),
          ]),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: firestoreGetWordsAll,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                padding: EdgeInsets.all(8.0),
                child: ListView(
                  children: snapshot.data.documents.map((word) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('${word.data['user']['userName']}'),
                              Text(
                                '${word.data['createdAt'].toDate().toString().substring(0, 19)}',
                                style: TextStyle(fontSize: 9.0),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${word.data['body']}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FutureBuilder<String>(
                                  future: getCurrentUserId(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.done) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    final uid = snapshot.data;
                                    return LikeButton(
                                      circleColor: CircleColor(
                                          start: Colors.orange,
                                          end: Colors.pinkAccent),
                                      bubblesColor: BubblesColor(
                                        dotPrimaryColor: Colors.orange,
                                        dotSecondaryColor: Colors.pinkAccent,
                                      ),
                                      likeBuilder: (bool isLiked) {
                                        return Icon(
                                          Icons.favorite,
                                          color: isLiked
                                              ? Colors.pink[300]
                                              : Colors.grey,
                                        );
                                      },
                                      likeCount:
                                          (word.data['likes'] ?? []).length,
                                      isLiked: (word.data['likes'] ?? [])
                                          .contains(uid),
                                      onTap: (isLiked) async {
                                        final ref = Firestore.instance
                                            .collection('wordOfToday')
                                            .document(word.documentID);
                                        if (isLiked) {
                                          ref.setData({
                                            'likes':
                                                FieldValue.arrayRemove([uid])
                                          }, merge: true);
                                        } else {
                                          ref.setData({
                                            'likes':
                                                FieldValue.arrayUnion([uid])
                                          }, merge: true);
                                        }
                                        return isLiked;
                                      },
                                      countBuilder: (int count, bool isLiked,
                                          String text) {
                                        var color = isLiked
                                            ? Colors.pink[300]
                                            : Colors.grey;
                                        Widget result;
                                        if (count == 0) {
                                          result = Text(
                                            "感謝",
                                            style: TextStyle(color: color),
                                          );
                                        } else
                                          result = Text(
                                            count >= 1000
                                                ? (count / 1000.0)
                                                        .toStringAsFixed(1) +
                                                    "k"
                                                : text,
                                            style: TextStyle(color: color),
                                          );
                                        return result;
                                      },
                                    );
                                  }),
                              FutureBuilder(
                                future: getCurrentUserId(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final currentUserId = snapshot.data;
                                    return _isCheckPost.isMyPost(
                                            '${word.data['user']['userId']}',
                                            currentUserId)
                                        ? GestureDetector(
                                            child: Icon(
                                              Icons.dehaze,
                                              size: 18.0,
                                            ),
                                            onTap: () {
                                              print(TabInherited.of(context));
                                              // TabInherited.of(context)
                                              //     .openTab(0);
                                              return Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      WordOfTodayEditAndDel(
                                                    wordId: word.documentID,
                                                    // onDeleted: () {
                                                    //   TabInherited.of(context)
                                                    //       .openTab(1);
                                                    // },
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Text('');
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              )
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class TabInherited extends InheritedWidget {
  final void Function(int index) openTab;
  final Widget child;

  TabInherited({@required this.openTab, @required this.child})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static TabInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabInherited>();
  }
}
