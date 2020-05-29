import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/make_post.dart';
import 'package:flutter_bbs/word_of_today.dart';
import 'bottom_navigation.dart';

class PostWordOfToday extends StatelessWidget {
  TextEditingController _textEditingController = TextEditingController();
  var _auth = FirebaseAuth.instance;
  final wordOfTodayCollectionRef = Firestore.instance.collection('wordOfToday');

  getUserData(uid) async {
    final userDocument =
        await Firestore.instance.collection('users').document(uid).get();

    var userRecord = userDocument.data;

    return userRecord;
  }

  getCurrentUser() async {
    var currentUser = await _auth.currentUser();
    var curentUserInfo = await getUserData(currentUser.uid);
    var userName = await curentUserInfo['userName'];
    var imageUrl = await curentUserInfo['userImageUrl'];

    var userDatas = {
      'userId': currentUser.uid,
      'userName': userName,
      'imageUrl': imageUrl,
    };
    return userDatas;
  }

  void createPostWordData(message) async {
    var user = await getCurrentUser();

    var postData = {
      'body': message,
      'createdAt': new DateTime.now(),
      'postId': new DateTime.now().toString() + user['userId'],
      'thanksCount': 0,
      'user': {
        'userId': await user['userId'],
        'userName': await user['userName'],
        'userImageUrl': await user['imageUrl'],
      }
    };
    wordOfTodayCollectionRef.document().setData(postData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('一言投稿画面'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 80,
            child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 0),
                  color: Colors.white.withOpacity(0.7),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: _textEditingController,
                      onChanged: (String title) {
                        title = _textEditingController.text;
                      },
                      decoration: InputDecoration(
                        labelText: '今日の一言',
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
                  child: RaisedButton(
                    color: Colors.lightBlue[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      createPostWordData(_textEditingController.text);
                      // Navigator.of(context).pushReplacement(
                      //   MaterialPageRoute(
                      //     builder: (context) => BottomNavigation(pageNumber: 2),
                      //   ),
                      // );
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      '投稿',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          letterSpacing: 9.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
