import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/firestore/connect_firestore_post.dart';

import 'bottom_navigation.dart';
import 'home_screen.dart';

class MakePost extends StatelessWidget {
  TextEditingController _titleTextController = TextEditingController();
  TextEditingController _bodyTextController = TextEditingController();
  ConnectFirestorePost _connectFirestorePost = ConnectFirestorePost();
  FirebaseUser currentUser;

  var _auth = FirebaseAuth.instance;

  getUserData(uid) async {
    final userDocument =
        await Firestore.instance.collection('users').document(uid).get();

    var userRecord = userDocument.data;

    return userRecord;
  }

  _getCurrentUser() async {
    currentUser = await _auth.currentUser();
    var curentUserInfo = await getUserData(currentUser.uid);
    var userName = await curentUserInfo['userName'];
    var userCategory = curentUserInfo['category'];

    var userDatas = {
      'userId': currentUser.uid,
      'userName': userName,
      'category': userCategory
    };
    return userDatas;
  }

  final postCollectionRef = Firestore.instance.collection('posts');

  void createPostData(title, message) async {
    var user = await _getCurrentUser();
    var postData = {
      'title': title,
      'body': message,
      'createdAt': new DateTime.now(),
      'postId': new DateTime.now().toString() + user['userId'],
      'replyCount': 0,
      'user': {
        'userId': await user['userId'],
        'userName': await user['userName'],
        'category': await user['category']
      }
    };
    postCollectionRef.document().setData(postData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('新規投稿'),
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
                      controller: _titleTextController,
                      onChanged: (String title) {
                        title = _titleTextController.text;
                      },
                      decoration: InputDecoration(
                        labelText: 'title',
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
                  margin: EdgeInsets.fromLTRB(16.0, 0.2, 16.0, 0),
                  color: Colors.white.withOpacity(0.7),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: _bodyTextController,
                      onChanged: (String body) {
                        body = _bodyTextController.text;
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.grey,
                        labelText: 'message',
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
                      createPostData(
                          _titleTextController.text, _bodyTextController.text);
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
