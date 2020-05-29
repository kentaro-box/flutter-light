import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/home_screen.dart';

import 'bottom_navigation.dart';

class EditAndDelete extends StatelessWidget {
  String postId;
  EditAndDelete({this.postId});
  final _formKey = GlobalKey<FormState>();
  TextEditingController _updataTitleTextEditingController;
  TextEditingController _updataBodyTextEditingController;

  Future getPost(String postId) async {
    DocumentSnapshot post =
        await Firestore.instance.collection('posts').document(postId).get();
    return post.data;
  }

  updatePost(data) {
    var updateFields = Firestore.instance.collection('posts').document(postId);

    updateFields.setData(data, merge: true);
  }

  deletePost() {
    var deletePost = Firestore.instance.collection('posts').document(postId);
    deletePost.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.lightBlue[300], Colors.cyan[100]])),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: FutureBuilder(
              future: getPost(postId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            controller: _updataTitleTextEditingController =
                                TextEditingController(
                                    text: snapshot.data['title']),
                            keyboardType: TextInputType.text,
                            // initialValue: null,
                            decoration: InputDecoration(
                                // hintText: snapshot.data['title'],
                                ),
                            validator: (updataTitleValue) {
                              if (updataTitleValue.isEmpty) {
                                return 'Please enter title';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: _updataBodyTextEditingController =
                                TextEditingController(
                                    text: snapshot.data['body']),
                            // initialValue: null,
                            decoration: InputDecoration(
                                // hintText: snapshot.data['body'],
                                ),
                            validator: (updataBodyValue) {
                              if (updataBodyValue.isEmpty) {
                                return 'Please enter body';
                              }
                              return null;
                            },
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: RaisedButton(
                                    onPressed: () {
                                      var data = {
                                        'title':
                                            _updataTitleTextEditingController
                                                .text,
                                        'body': _updataBodyTextEditingController
                                            .text
                                      };
                                      updatePost(data);
                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         BottomNavigation(pageNumber: 1),
                                      //   ),
                                      // );
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('変更'),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: RaisedButton(
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: Text('削除しますか？'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('キャンセル'),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                              ),
                                              FlatButton(
                                                child: Text('削除する'),
                                                onPressed: () {
                                                  deletePost();
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BottomNavigation(),
                                                    ),
                                                  );
                                                },
                                              )
                                            ],
                                          );
                                        }),

                                    // {
                                    //   deletePost();
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         BottomNavigation(pageNumber: 1),
                                    //   ),
                                    // );
                                    //   Navigator.of(context).pop(true);
                                    // },
                                    child: Text('削除'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
              }),
        ),
      ),
    );
  }
}
