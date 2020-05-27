import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbs/home_screen.dart';

import 'word_of_today.dart';

class WordOfTodayEditAndDel extends StatelessWidget {
  final void Function() onDeleted;
  String wordId;
  WordOfTodayEditAndDel({this.wordId, @required this.onDeleted});
  final _formKey = GlobalKey<FormState>();
  TextEditingController _updataBodyTextEditingController;

  Future getPost(String wordId) async {
    DocumentSnapshot post = await Firestore.instance
        .collection('wordOfToday')
        .document(wordId)
        .get();
    return post.data;
  }

  updatePost(data) {
    var updateFields =
        Firestore.instance.collection('wordOfToday').document(wordId);

    updateFields.setData(data, merge: true);
  }

  Future<void> deletePost() {
    var deletePost =
        Firestore.instance.collection('wordOfToday').document(wordId);
    return deletePost.delete();
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
      body: Container(
        padding: EdgeInsets.all(16),
        child: FutureBuilder(
            future: getPost(wordId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _updataBodyTextEditingController =
                              TextEditingController(
                                  text: snapshot.data['body']),
                          keyboardType: TextInputType.text,
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
                                      'body':
                                          _updataBodyTextEditingController.text
                                    };
                                    updatePost(data);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('変更'),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: RaisedButton(
                                  onPressed: () async {
                                    final result = await showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: Text('本当に削除しますか？'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('キャンセル'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                              FlatButton(
                                                child: Text('削除'),
                                                onPressed: () async {
                                                  await deletePost();
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                              )
                                            ],
                                          );
                                        });
                                    if (result == true) {
                                      Navigator.of(context).pop(true);
                                    }
                                  },
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
